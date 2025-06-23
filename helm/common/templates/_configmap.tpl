{{- define "common.configmap" }}
{{ $ := ._global }}
{{ $useTemplate := ( ne .useTemplate false )  }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  {{- if .suffix }}
  name: {{ include "common.fullname" $ }}-{{ .suffix }}
  {{- else }}
  name: {{ include "common.fullname" $ }}
  {{- end }}
  annotations:
    {{- if .annotations}}
    {{- .annotations | toYaml | nindent 4}}
    {{- end }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
    {{- if .labels }}
    {{- .labels | toYaml | nindent 4 }}
    {{- end }}
data:
  {{- include "common.cm-sec.data" . | nindent 2 }}
{{- end }}