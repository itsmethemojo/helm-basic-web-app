{{/*
Expand the name of the chart.
*/}}
{{- define "basic-web-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "basic-web-app.fullname" -}}
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
{{- define "basic-web-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "basic-web-app.labels" -}}
helm.sh/chart: {{ include "basic-web-app.chart" . }}
{{ include "basic-web-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "basic-web-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "basic-web-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "basic-web-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "basic-web-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a checksum for all env parameters in the secret.
Adds the checksum to podAnnotations to ensure pod reloads on env secret changes.
*/}}
{{- define "basic-web-app.podAnnotations" -}}
{{- if .Values.env -}}
{{- $allKsAndVs := list -}}
{{- range $k, $v := .Values.env -}}
{{- $allKsAndVs = append $allKsAndVs $k -}}
{{- $allKsAndVs = append $allKsAndVs $v -}}
{{- end -}}
{{- $envChecksum := join "," $allKsAndVs  | sha256sum | printf "%.*s" 60 -}}
{{ toYaml (set .Values.podAnnotations "envChecksum" $envChecksum) }}
{{- else -}}
{{ toYaml .Values.podAnnotations }}
{{- end -}}
{{- end -}}
