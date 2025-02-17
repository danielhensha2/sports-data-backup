[
  {
    "name": "${container_name}",
    "image": "${image}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${aws_region}",
        "awslogs-group": "${log_group_name}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": [
      {
        "name": "API_URL",
        "value": "${api_url}"
      },
      {
        "name": "RAPIDAPI_HOST",
        "value": "${rapidapi_host}"
      },
      {
        "name": "LEAGUE_NAME",
        "value": "${league_name}"
      },
      {
        "name": "DATE",
        "value": "${date}"
      },
      {
        "name": "LIMIT",
        "value": "${limit}"
      },
      {
        "name": "INPUT_KEY",
        "value": "${input_key}"
      },
      {
        "name": "OUTPUT_KEY",
        "value": "${output_key}"
      },
      {
        "name": "AWS_REGION",
        "value": "${aws_region}"
      },
      {
        "name": "S3_BUCKET_NAME",
        "value": "${s3_bucket_name}"
      },
      {
        "name": "MEDIACONVERT_ENDPOINT",
        "value": "${mediaconvert_endpoint}"
      },
      {
        "name": "RETRY_COUNT",
        "value": "${retry_count}"
      },
      {
        "name": "RETRY_DELAY",
        "value": "${retry_delay}"
      },
      {
        "name": "WAIT_TIME_BETWEEN_SCRIPTS",
        "value": "${wait_time_between_scripts}"
      },
      {
        "name": "MEDIACONVERT_ROLE_ARN",
        "value": "${mediaconvert_role_arn}"
      },
      {
        "name": "DYNAMODB_TABLE",
        "value": "${dynamodb_table}"
      }
    ],
    "secrets": [
      {
        "name": "RAPIDAPI_KEY",
        "valueFrom": "${rapidapi_ssm_parameter_arn}"
      }
    ]
  }
]
