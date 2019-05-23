[
    {
        "name": "datadog-agent",
        "image": "datadog/agent:latest",
        "cpu": 10,
        "memory": 256,
        "essential": true,
        "logConfiguration": {
			"logDriver": "json-file",
			"options": {
				"mode": "non-blocking",
				"max-size": "100m",
				"max-file": "2"
			}
		},
        "mountPoints": [
            {
                "containerPath": "/var/run/docker.sock",
                "sourceVolume": "docker_sock",
                "readOnly": true
            },
            {
                "containerPath": "/host/sys/fs/cgroup",
                "sourceVolume": "cgroup",
                "readOnly": true
            },
            {
                "containerPath": "/host/proc",
                "sourceVolume": "proc",
                "readOnly": true
            },
            {
                "containerPath": "/opt/datadog-agent/run",
                "sourceVolume": "pointdir",
                "readOnly": false
            }
        ],
        "environment": [
            {
                "name": "DD_API_KEY",
                "value": "${DD_API_KEY}"
            },
            {
                "name": "DD_SITE",
                "value": "${DD_SITE}"
            },
            {
                "name": "DD_LOGS_ENABLED",
                "value": "true"
            },
            {
                "name": "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL",
                "value": "true"
            },
            {
                "name": "DD_APM_ENABLED",
                "value": "false"
            },
            {
                "name": "DD_PROCESS_AGENT_ENABLED",
                "value": "false"
            },
            {
                "name": "DD_LOG_LEVEL",
                "value": "${log_level}"
            },
            {
                "name": "DD_ENABLE_PAYLOADS_EVENTS",
                "value": "false"
            },
            {
                "name": "DD_ENABLE_PAYLOADS_SERIES",
                "value": "false"
            },
            {
                "name": "DD_ENABLE_PAYLOADS_SERVICE_CHECKS",
                "value": "false"
            },
            {
                "name": "DD_ENABLE_PAYLOADS_SKETCHES",
                "value": "false"
            }
        ]
    }
]