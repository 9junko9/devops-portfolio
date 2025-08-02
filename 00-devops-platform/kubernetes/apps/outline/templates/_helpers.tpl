{{- /*
Return the full name: release-name + chart-name, truncated if needed
*/ -}}
{{- define "outline.fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Return the chart name
*/ -}}
{{- define "outline.name" -}}
{{ .Chart.Name }}
{{- end }}
