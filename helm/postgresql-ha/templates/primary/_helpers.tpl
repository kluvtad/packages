
{{/*
Primary labels
*/}}
{{- define "postgresql-ha.primary.labels" -}}
helm.sh/chart: {{ include "postgresql-ha.chart" . }}
{{ include "postgresql-ha.primary.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Primary Selector labels
*/}}
{{- define "postgresql-ha.primary.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql-ha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: primary
{{- end }}

{{/*
Config names
*/}}
{{- define "postgresql-ha.primary.configmap.users" -}}
{{- if .Values.users.existingConfigmap -}}
{{- .Values.users.existingConfigmap -}}
{{- else -}}
{{ include "postgresql-ha.fullname" $ }}-users
{{- end }}
{{- end }}

{{- define "postgresql-ha.primary.configmap.databases" -}}
{{- if .Values.databases.existingConfigmap -}}
{{- .Values.databases.existingConfigmap -}}
{{- else -}}
{{ include "postgresql-ha.fullname" $ }}-databases
{{- end }}
{{- end }}