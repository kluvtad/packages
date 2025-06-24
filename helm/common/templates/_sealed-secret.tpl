{{- define "common.sealedSecret" }}
{{ $ := ._global }}
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  {{- if .nameSuffix }}
  name: {{ include "common.fullname" $ }}-{{ .nameSuffix }}
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
    {{- include "common.cm-sec.data" ( dict 
      "_global" $
      "config" .
    ) | nindent 4 }}
{{- end -}}