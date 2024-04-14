# litellm-cloudrun
This repo helps to deploy [LiteLLM](https://github.com/BerriAI/litellm) on Google Cloud Run with a few steps. 

**why need proxy?**
- Existing OpenAI users do not need to change the code. They only need to modify the base URL and API Key to access Gemini models.
- Build a proxy to solve the problem of inability to access Google API in China.
- Build a unified Gemini Proxy platform. Various applications can be directly connected using API Key. There is no need to integrate Service Account. 
- Various open source projects already support OpenAI, but do not support the Vertex Gemini model. With this, they will be compatible with all without major modifications.

## Prepare your Litellm config yaml file
modify the config.yaml

## Set env
```
export PROJECT_ID=speedy-victory-336109
export REGION=asia-east1
```
## Deploy LiteLLM proxy on CloudRun
```
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

## Clean
```
bash clean.sh
```
