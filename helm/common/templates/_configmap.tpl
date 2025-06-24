{{- define "common.configmap" }}
{{ $ := ._global }}
{{ $useTemplate := ( ne .useTemplate false )  }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  {{- if .name }}
  name: {{ .name | quote}}
  {{- else if .nameSuffix }}
  name: {{ include "common.fullname" $ }}-{{ .nameSuffix }}
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
  {{- include "common.cm-sec.data" ( dict 
    "_global" $
    "config" .
  ) | nindent 2 }}
{{- end }}