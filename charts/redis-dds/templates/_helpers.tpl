{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redis-dds.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis-dds.fullname" -}}
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
{{- define "redis-dds.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "redis-dds.labels" -}}
helm.sh/chart: {{ include "redis-dds.chart" . }}
{{ include "redis-dds.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "redis-dds.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-dds.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "redis-dds.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "redis-dds.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Vault annotations
*/}}
{{- define "generic.vaultAnnotations" -}}
{{- if .Values.authentication.enabled }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/tls-skip-verify: "true"
vault.hashicorp.com/role: "{{ .Values.vault.role }}"
{{- include "generic.vaultImportAnnotations" . }}
{{- end }}
{{- end }}

{{/*
Vault annotations
*/}}
{{- define "generic.vaultImportAnnotations" -}}
vault.hashicorp.com/agent-inject-secret-redisauth: "{{ .Values.authentication.vault }}"
vault.hashicorp.com/agent-inject-template-redisauth: |
  {{`{{- with secret `}}"{{ .Values.authentication.vault }}"{{` -}}`}}
  {{`{{ .Data.data.password }}`}}
  {{`{{- end }}`}}
{{- end }}
