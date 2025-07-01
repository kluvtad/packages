import os, subprocess, threading
from typing import List

def git_lock_decor(func):
    def inner(self, *args, **kwargs):
        if kwargs.get("locked"):
            res= func(self, *args, **kwargs)
        else:
            with self.thread_lock:
                res= func(self, *args, **kwargs)
        return res
    return inner

class GIT_CLIENT:
    work_tree = os.getenv('GIT_WORK_TREE')
    branch = os.getenv('GIT_BRANCH')
    subprocess_run_kwargs={
        "text": True, "capture_output": True, "check": True
    }
    thread_lock= threading.Lock()

    def __init__(self) -> None:
        return
    
    def status(self):
        subprocess.run(["git", "fetch", "origin", self.branch], **self.subprocess_run_kwargs)
        return {
            'branch': subprocess.run(["git", "branch", "--show-current"], **self.subprocess_run_kwargs).stdout, 
            'dirty_files': subprocess.run(["git", "status", "--porcelain"], **self.subprocess_run_kwargs).stdout.split('\n')[:-1]
        }
    
    def edit_yaml(self, file, key, value):
        file_path= os.path.join(self.work_tree, file)
        
        # edit and return file
        yq = subprocess.run(
            f'yq \'{key} = "{value}"\' {file_path}',
            shell= True, capture_output= True, check= True
        )
        # Check diff and keep comments + blank lines
        subprocess.run(
            f"diff -B {file_path} - | patch {file_path} - ",
            shell= True, input= yq.stdout, capture_output= True, check= True
        )

    @git_lock_decor
    def pull(self, *args, **kwargs):
        subprocess.run(
            ["git", "pull"], 
            **self.subprocess_run_kwargs
        )

    @git_lock_decor
    def commit(self, msg, descriptions: List[str] = [], *args, **kwargs):
        stats = self.status()
        if len(stats['dirty_files']):
            ls_desc_args = []
            for line in descriptions:
                ls_desc_args += ['-m', line]
            subprocess.run([
                'git', 'commit', '-am', msg,
                *ls_desc_args
                ], **self.subprocess_run_kwargs)
        else:
            return

    @git_lock_decor
    def reset_hard(self, dest= "HEAD", *args, **kwargs):
        subprocess.run(
            ['git', 'reset', '--hard', dest],
            **self.subprocess_run_kwargs
        )
    
    @git_lock_decor
    def merge(self, dest, *args, **kwargs):
        subprocess.run([
                'git', 'merge', 
                '-m', f"CI[{self.branch}]: Merge remote-tracking branch '{dest}' into staging",
                dest
            ], **self.subprocess_run_kwargs
        )

    def push(self):
        subprocess.run(
            ['git', 'push'],
            **self.subprocess_run_kwargs
        )
        return 
    