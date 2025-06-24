import httpx
from litellm.llms.custom_llm import CustomLLM
from litellm.utils import ModelResponse

class MyLlamaCppLLM(CustomLLM):
    def __init__(self):
        self.timeout = 60  # Set default timeout
        
    def completion(self, model, messages, **kwargs):
        # Build prompt from messages
        prompt = ""
        for msg in messages:
            if msg["role"] == "user":
                prompt += f"User: {msg['content']}\n"
            elif msg["role"] == "assistant":
                prompt += f"Assistant: {msg['content']}\n"
            elif msg["role"] == "system":
                prompt += f"System: {msg['content']}\n"
        
        # Prepare API call
        api_base = kwargs.get("api_base", "http://model:8001")
        url = f"{api_base.rstrip('/')}/completion"
        payload = {
            "prompt": prompt,
            "temperature": kwargs.get("temperature", 0.7),
            "max_tokens": kwargs.get("max_tokens", 100),
            "top_p": kwargs.get("top_p", 1.0)
        }
        
        # Make request
        try:
            response = httpx.post(url, json=payload, timeout=self.timeout)
            response.raise_for_status()
            data = response.json()
            
            # Build ModelResponse
            model_response = ModelResponse()
            choice = model_response.choices[0]
            choice.message = {"content": data["content"]}
            choice.finish_reason = data.get("stop_reason", "stop")
            
            return model_response
        except Exception as e:
            raise Exception(f"Llama.cpp API error: {str(e)}")

my_llama_cpp_llm = MyLlamaCppLLM()
