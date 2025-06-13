{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "common.cm-sec.data" -}}
{{ $useTemplate := ( ne .useTemplate false )  }}

{{- if hasKey . "data" }}
{{- .data | toYaml }}

{{- else if hasKey . "fileMappings" }}
{{- range $k, $v := .fileMappings }}
{{ $k | quote }}: |
{{- if $useTemplate }}
{{- tpl ( $.Files.Get $v ) $ | nindent 2 }}
{{- else }}
{{- $.Files.Get $v | nindent 2}}
{{- end }}
{{- end }}

{{- else if hasKey . "dataFromFile" }}
{{- if $useTemplate }}
{{- tpl ( $.Files.Get .dataFromFile  ) $ }}
{{- else }}
{{- $.Files.Get .dataFromFile }}
{{- end }}

{{- else if hasKey . "dataFromDir" }}
{{- range $path, $bytes  := $.Files.Glob .dataFromDir }}
{{ base $path }}: |
{{- tpl ($.Files.Get $path) $ | nindent 2 }}
{{- end }}
{{- end }}

{{- else -}}
{{- fail "No valid data found. Must specify either 'data', 'fileMappings', 'dataFromFile', or 'dataFromDir'." -}}
{{- end }}

{{- end -}}