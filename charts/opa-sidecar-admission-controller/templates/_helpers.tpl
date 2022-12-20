{{/*
Expand the name of the chart.
*/}}
{{- define "opa-sidecar-admission-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand a default fully qualified app name.
*/}}
{{- define "opa-sidecar-admission-controller.fullname" -}}
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
Expand the chart name and version as used by the chart label.
*/}}
{{- define "opa-sidecar-admission-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the service name
*/}}
{{- define "opa-sidecar-admission-controller.serviceName" -}}
{{ include "opa-sidecar-admission-controller.fullname" . }}
{{- end }}

{{/*
Common labels
Includes the default istio/kiali pod labels, app: and version:
Includes the standard helm labels
*/}}
{{- define "opa-sidecar-admission-controller.labels" -}}
app: {{ include "opa-sidecar-admission-controller.fullname" . }}
version: {{ .Chart.AppVersion | quote }}
{{ include "opa-sidecar-admission-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "opa-sidecar-admission-controller.chart" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opa-sidecar-admission-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opa-sidecar-admission-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
Expand the service account name
*/}}
{{- define "opa-sidecar-admission-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opa-sidecar-admission-controller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}