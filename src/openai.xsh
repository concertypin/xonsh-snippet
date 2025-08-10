#!/usr/bin/env python
"""
OpenAI compatible chat REPL for Xonsh.
env variables:
    OPENAI_API_KEY: OpenAI API key
    OPENAI_API_ENDPOINT: OpenAI-compatible API endpoint (default: https://api.openai.com/v1)
    OPENAI_API_MODEL: LLM model (default: DeepSeek-R1-0528)
Gemini-chan wrote this code. I think this can't be copyrighted. So, you can use this code without any restrictions.
"""

def __openai__():
    class Prompt:
        txt:str
        role:str=""
        def __init__(self, *txt):
            self.txt=" ".join(txt)
        def dict(self)->dict[str,str]:
            return {"role":self.role, "content":self.txt}
    class User(Prompt):
        role="user"
    class Assistant(Prompt):
        role="assistant"
    class System(Prompt):
        role="system"

    system_prompt_template=[
        System("Your",
            "Sysprompt",
            "Here"
        )
    ]

    def handler(i:str)->str|None:
        if(i.startswith("/cot")):
            print(messages[-1]["content"])

    from openai import OpenAI
    import os, re
    class StreamingTagRemover:
        def __init__(self):
            self.buffer = ""
            self.in_tag = False
            self.open_tag = f"<think>"
            self.close_tag = f"</think>"
        def feed(self, chunk: str) -> str:
            self.buffer += chunk
            output = ""

            while True:
                if not self.in_tag:
                    start = self.buffer.find(self.open_tag)
                    if start != -1:
                        output += self.buffer[:start]
                        self.buffer = self.buffer[start + len(self.open_tag):]
                        self.in_tag = True
                    else:
                        safe_end = max(self.buffer.rfind("<"), 0)
                        maybe_tag = self.buffer[safe_end:]
                        real_output = self.buffer[:safe_end]
                        self.buffer = maybe_tag
                        output += real_output
                        break
                else:
                    end = self.buffer.find(self.close_tag)
                    if end != -1:
                        self.buffer = self.buffer[end + len(self.close_tag):]
                        self.in_tag = False
                    else:
                        break

            return output
    client=OpenAI(api_key=$OPENAI_API_KEY, base_url=$OPENAI_API_ENDPOINT)
    def get_chat_completion(messages: list[dict]):
        response = client.chat.completions.create(
            model=os.getenv("OPENAI_API_MODEL"),
            messages=list(map(lambda i:i if isinstance(i, dict) else i.dict(),messages)),
            stream=True,
        )
        return response

    print("💬 OpenAI 호환 챗 REPL 시작! 종료하려면 Ctrl+C...")
    messages = system_prompt_template+[] #deepcopy hack

    try:
        while True:
            user_input = input("🙋 유저: ")
            if not user_input.strip():
                break
            messages.append({"role": "user", "content": user_input})

            print("🤖 봇: ", end=" ")
            response_stream = get_chat_completion(messages)
            full_response = ""
            for chunk in response_stream:
                delta = chunk.choices[0].delta
                if delta is not None:
                    content = delta.content
                    full_response += content
                    print(content, end="", flush=True)
            print()
            messages.append({"role": "assistant", "content": full_response})
    except (KeyboardInterrupt, EOFError) as _:
        print("\n👋 종료합니다!")

aliases["openai"]=lambda: __openai__()