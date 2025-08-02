{{- define "outline.name" -}}
{{- printf "%s" .Chart.Name -}}
{{- end -}}

{{- define "outline.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "outline.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
