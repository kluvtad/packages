{{- define "common.sealedSecret" }}
{{ $ := ._global }}
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  {{- if .suffix }}
  name: {{ include "common.fullname" $ }}-{{ .suffix }}
  {{- else }}
  name: {{ include "common.fullname" $ }}
  {{- end }}
  annotations:
    {{- if .sealedAnnotations }}
    {{- .sealedAnnotations | toYaml | nindent 4 }}
    {{- end }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
    {{- if .sealedLabels }}
    {{- .sealedLabels | default dict | toYaml | nindent 4 }}
    {{- end }}
spec:
  template:
    type: {{ default "Opaque" .type }}
    metadata:
      labels:
        {{- include "common.labels" $ | nindent 8 }}
        {{- if .labels }}
        {{- .labels | toYaml | nindent 8 }}
        {{- end }}
      annotations:
        {{- if .annotations }}
        {{- .annotations | toYaml | nindent 8 }}
        {{- end }}

  encryptedData:
    {{- if hasKey . "data" }}
    {{- .data | toYaml | nindent 4 }}
    {{- else if hasKey . "dataFromFile" }}
    {{- range $k, $v := .dataFromFile }}
    {{ $k | quote }}: |
      {{- tpl ( $v | $.Files.Get ) $ | nindent 6 }}
    {{- end }}
    {{- else if hasKey . "file" }}
    {{- tpl ( .file | $.Files.Get ) $ | nindent 4 }}
    {{- end }}
{{- end -}}