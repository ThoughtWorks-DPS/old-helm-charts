{{/*
Expand the name of the chart.
*/}}
{{- define "opa-sidecar-injector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opa-sidecar-injector.fullname" -}}
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
{{- define "opa-sidecar-injector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the default admission controller image tag.
*/}}
{{- define "opa-sidecar-injector.imageTag" -}}
{{- printf "%s-rootless" .Chart.AppVersion }}
{{- end }}

{{/*
Expand the service account name
*/}}
{{- define "opa-sidecar-injector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opa-sidecar-injector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the service name
*/}}
{{- define "opa-sidecar-injector.serviceName" -}}
{{ include "opa-sidecar-injector.fullname" . }}-admission-controller
{{- end }}


{{/*
Common labels
Includes the default istio/kiali pod labels, app: and version:
Includes the standard helm labels
*/}}
{{- define "opa-sidecar-injector.labels" -}}
app: {{ include "opa-sidecar-injector.fullname" . }}
version: {{ .Chart.AppVersion | quote }}
{{ include "opa-sidecar-injector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "opa-sidecar-injector.chart" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opa-sidecar-injector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opa-sidecar-injector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create default certificate-init-container parameters
*/}}
{{- define "opa-sidecar-injector.certificate.commonName" -}}
certificate-init-contianer
{{- end }}
{{- define "opa-sidecar-injector.certificate.organization" -}}
Org
{{- end }}
{{- define "opa-sidecar-injector.certificate.organizationalUnit" -}}
Unit
{{- end }}
{{- define "opa-sidecar-injector.certificate.country" -}}
USA
{{- end }}
{{- define "opa-sidecar-injector.certificate.province" -}}
CA
{{- end }}
{{- define "opa-sidecar-injector.certificate.locality" -}}
City
{{- end }}
{{- define "opa-sidecar-injector.certificate.streetAddress" -}}
Address
{{- end }}
{{- define "opa-sidecar-injector.certificate.postalCode" -}}
10001
{{- end }}
{{- define "opa-sidecar-injector.certificate.certDir" -}}
/etc/tls
{{- end }}

{{/*
Create default mutatingwebhook-init-container parameters
*/}}
{{- define "opa-sidecar-injector.mutatingWebhook.serviceNames" -}}
{{ include "opa-sidecar-injector.serviceName" . }}
{{- end }}
{{- define "opa-sidecar-injector.mutatingWebhook.serviceNamespace" -}}
$(NAMESPACE)
{{- end }}

{{/*
Expand default injection template
*/}}
{{- define "opa-sidecar-injector.injectionPolicy" -}}
    package istio

    inject = {
      "apiVersion": "admission.k8s.io/v1beta1",
      "kind": "AdmissionReview",
      "response": {
        "allowed": true,
        "patchType": "JSONPatch",
        "patch": base64.encode(json.marshal(patch)),
      },
    }

    patch = [{
      "op": "add",
      "path": "/spec/containers/-",
      "value": opa_container,
    }, {
      "op": "add",
      "path": "/spec/volumes/-",
      "value": opa_config_volume,
    }]

    opa_container = {
      "name": "opa",
      "image": "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}-envoy-rootless",
      "args": [
        "run",
        "--server",
        "--ignore=.*",
        "--config-file=/config/conf.yaml",
        "--authentication=token",
        "--addr=localhost:8181",
        "--diagnostic-addr=0.0.0.0:8282"
      ],
      "volumeMounts": [{
        "mountPath": "/config",
        "name": "{{ include "opa-sidecar-injector.opaSidecarConfig" . }}",
      }],
      "readinessProbe": {
        "httpGet": {
          "path": "/health?plugins",
          "scheme": "HTTP",
          "port": 8282,
        },
        "initialDelaySeconds": 5,
        "periodSeconds": 5,
      },
      "livenessProbe": {
        "httpGet": {
          "path": "/health?plugins",
          "scheme": "HTTP",
          "port": 8282,
        },
        "initialDelaySeconds": 5,
        "periodSeconds": 5,
      }
    }
    
    opa_config_volume = {
      "name": "{{ include "opa-sidecar-injector.opaSidecarConfig" . }}",
      "configMap": {"name": "{{ include "opa-sidecar-injector.opaSidecarConfig" . }}"},
    }
      
{{- end }}

{{/*
Expand default opa sidecar config configmap name
*/}}
{{- define "opa-sidecar-injector.opaSidecarConfig" -}}
{{- default "opa-sidecar-config" .Values.opaSidecarConfig }}
{{- end }}