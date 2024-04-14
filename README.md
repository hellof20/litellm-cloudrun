# LiteLLM-CloudRun
This repo helps to deploy [LiteLLM](https://github.com/BerriAI/litellm) on Google Cloud Run with a few steps. 

**why need proxy?**
- Existing OpenAI users do not need to change the code. They only need to modify the base URL and API Key to access Gemini models.
- Build a proxy to solve the problem of inability to access Google API in China.
- Build a unified Gemini Proxy platform. Various applications can be directly connected using API Key. There is no need to integrate Service Account. 
- Various open source projects already support OpenAI, but do not support the Vertex Gemini model. With this, they will be compatible with all without major modifications.

## Prepare your LiteLLM config yaml file
Edit config.yaml
1. modify "vertex_project" and "vertex_location"
2. modify "master_key"

## Deploy LiteLLM proxy on CloudRun
```
export PROJECT_ID=your_project_id
export REGION=region_name
bash deploy.sh
```
## Test
- use curl to test
```
curl -X POST https://change_to_your_cloud_run_url/chat/completions \
-H 'Authorization: Bearer change_to_your_apk_key' \
-d '{
    "model": "change_to_your_model_name", 
    "messages": [{"role": "user","content": "what llm are you"}]
    }'
```
sample result:
```
{"id":"chatcmpl-abf4eb0b-b275-47f8-8e36-b0649c43c346","choices":[{"finish_reason":"stop","index":0,"message":{"content":"I am Gemini, a multi-modal AI model, developed by Google.","role":"assistant"}}],"created":1713067892,"model":"gemini-1.0-pro-001","object":"chat.completion","system_fingerprint":null,"usage":{"prompt_tokens":5,"completion_tokens":15,"total_tokens":20}}
```

## Update your config.yaml file
1. Upload your new config.yaml to a new secret version
```
gcloud secrets versions add litellm-config \
    --data-file="config.yaml" \
    --project=${PROJECT_ID}
```
2. Reload the Cloud Run service
```
gcloud run services update litellm-proxy-001 \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --set-secrets=/app/config.yaml=litellm-config:latest
```

## Clean
```
export PROJECT_ID=your_project_id
export REGION=region_name
bash clean.sh
```
