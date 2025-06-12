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
    {{ .annotations | toYaml | nindent 4}}
    {{- end }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
data:
  {{- if hasKey . "data" }}
  {{- .data | toYaml | nindent 2 }}
  {{- else if hasKey . "dataFromFile" }}
  {{- range $k, $v := .dataFromFile }}
  {{ $k | quote }}: |
    {{- if $useTemplate }}
    {{- tpl ( $.Files.Get $v ) $ | nindent 4 }}
    {{- else }}
    {{- $.Files.Get $v | nindent 4}}
    {{- end }}
  {{- end }}
  {{- else if hasKey . "file" }}
  {{- if $useTemplate }}
  {{- tpl ( $.Files.Get .file  ) $ | nindent 2 }}
  {{- else }}
  {{- $.Files.Get .file  | nindent 2}}
  {{- end }}
  {{- end }}
{{- end }}