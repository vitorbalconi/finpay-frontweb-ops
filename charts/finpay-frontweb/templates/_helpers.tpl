{{- define "finpay-frontweb.name" -}}
finpay-frontweb
{{- end }}

{{- define "finpay-frontweb.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "finpay-frontweb.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "finpay-frontweb.labels" -}}
app.kubernetes.io/name: {{ include "finpay-frontweb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.appVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "finpay-frontweb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "finpay-frontweb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "finpay-frontweb.image" -}}
{{- if .Values.image.digest -}}
{{- printf "%s@sha256:%s" .Values.image.repository (.Values.image.digest | trimPrefix "sha256:") -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) -}}
{{- end -}}
{{- end }}
