[
	{
		"dnsSearchDomains": null,
		"entryPoint": null,
		"logConfiguration": {
			"logDriver": "json-file",
			"options": {
				"mode": "non-blocking",
				"max-size": "500m",
				"max-file": "2"
			}
		},
		"command": [
			"-f",
			"${flog_type}",
        	"-l",
			"-d",
			"${flog_delay}"
      	],
		"linuxParameters": null,
		"cpu": ${cpu_shares},
		"memory": ${memory},
		"image": "mingrammer/flog",
		"name": "${service_name}"
	}
]