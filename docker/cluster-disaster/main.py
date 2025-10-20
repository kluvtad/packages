import logging
import os
import math
import random
import time
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor

from kubernetes import client, config
from pydantic import Field
from pydantic_settings import BaseSettings

logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')
logger = logging.getLogger()

class Settings(BaseSettings):
    restart_timeout: int = Field(300, alias = 'RESTART_TIMEOUT')
    allowed_namespaces: str = Field(alias = 'ALLOWED_NAMESPACES')

    @property
    def ls_namespaces(self) -> list[str]:
        return self.allowed_namespaces.split(',')

settings = Settings()
try:
    config.load_kube_config()
except:
    config.load_incluster_config()

k8s_v1 = client.CoreV1Api()
k8s_api = client.AppsV1Api()

def restart_deployment(namespace: str, deployment_name: str) -> None:
    deploy = k8s_api.read_namespaced_deployment(name=deployment_name, namespace=namespace)
    
    if deploy is None:
        logger.error(f"Deployment {deployment_name} not found in namespace {namespace}")
        return
    if deploy.spec.selector.match_expressions is not None:
        logger.warning("Currently only support match_labels selector")
        return
    if deploy.status.ready_replicas != deploy.status.replicas:
        logger.warning(f"Deployment {deploy.metadata.name} in namespace {namespace} is not fully ready, skip")
        return
    
    try:
        alpha = deploy.metadata.annotations.get('cluster-disaster/alpha', 5)
        alpha = int(alpha)
        assert alpha > 0
    except:
        alpha = 5

    ls_pods = k8s_v1.list_namespaced_pod(
        namespace= namespace, 
        label_selector= ','.join([f"{k}={v}" for k, v in deploy.spec.selector.match_labels.items()])
    ).items
    dt_now = datetime.now(timezone.utc)

    for pod in ls_pods:
        ls_pod_start_times = [i.state.running.started_at for i in pod.status.container_statuses]

        age_day = min([(dt_now - i).total_seconds() / 86400 for i in ls_pod_start_times])

        if random.random() < 1 - 1 / math.exp(age_day / (alpha * 100)):
            k8s_v1.delete_namespaced_pod(name= pod.metadata.name, namespace= pod.metadata.namespace)

            time.sleep(1)
            s = time.time()
            while True:
                watched_deploy = k8s_api.read_namespaced_deployment(name= deploy.metadata.name, namespace= deploy.metadata.namespace)
                if watched_deploy.status.ready_replicas == watched_deploy.status.replicas:
                    logger.info(f"Deleted pod {pod.metadata.name} in namespace {namespace}, age in days: {int(age_day * 100) / 100}")
                    break
                
                if time.time() - s > settings.restart_timeout:
                    logger.warning(f"Timeout waiting for deployment {deploy.metadata.name} in namespace {namespace} to be ready after restart a pod!")
                    break

                time.sleep(10)

if __name__ == "__main__":
    # Get all deployments with annotation cluster-disaster/restarted = "true"
    ls_restarted_deployments = []
    for namespace in settings.ls_namespaces:
        for deploy in k8s_api.list_namespaced_deployment(namespace= namespace).items:
            if bool(deploy.metadata.annotations.get('cluster-disaster/restarted', False)) == True:
                ls_restarted_deployments.append((deploy.metadata.namespace, deploy.metadata.name))

    # Restart deployments in parallel
    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(
            restart_deployment, namespace, deployment_name
        ) for namespace, deployment_name in ls_restarted_deployments]
    results = [future.result() for future in futures]

    logger.info("Done!")