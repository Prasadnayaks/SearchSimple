import google.generativeai as genai
from config import Settings
import re # Import regular expressions for keyword matching

settings = Settings()


class LLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        # Using gemini-1.5-flash-latest as a generally capable and fast model
        # If you have a specific preference or access to another model (e.g., "gemini-1.0-pro"),
        # you can adjust this.
        self.model = genai.GenerativeModel("gemini-2.0-flash-exp")
        print(f"[LLMService] Initialized with model: {self.model.model_name}")


    def _is_code_related_query(self, query: str) -> bool:
        """
        Simple check to see if the query is likely asking for code.
        This can be expanded with more sophisticated methods if needed.
        """
        query_lower = query.lower()
        code_keywords = [
            "code for", "flutter code", "dart code", "python code", "javascript code",
            "example of", "how to implement", "snippet for", "write a function",
            "generate code", "simple code for"
        ]
        # Check for keywords and also for phrases like "give me the ... code"
        if any(keyword in query_lower for keyword in code_keywords):
            return True
        if re.search(r"(give|show|provide) me (the|a|an) .*code", query_lower):
            return True
        return False

    def generate_response(self, query: str, search_results: list[dict]):
        context_text = "\n\n".join(
            [
                f"Source {i+1} ({result['url']}):\n{result['content']}"
                for i, result in enumerate(search_results)
            ]
        )

        is_code_query = self._is_code_related_query(query)
        print(f"[LLMService] Query: '{query}' - Is code related: {is_code_query}")

        if is_code_query:
            # Prompt optimized for code generation
            # For code queries, we might rely less on generic web context unless it's highly relevant
            # or even skip it if the model is capable enough.
            # For this version, we'll still provide context but give stronger instructions for code.
            full_prompt = f"""
You are an expert programming assistant. The user is asking for a code example.
Query: "{query}"

Context from web search (use this to understand the user's requirement if it's helpful, but prioritize generating correct and runnable code using your own knowledge if the context is insufficient or not directly providing a code solution):
{context_text if context_text.strip() else "No specific web context provided or it was empty."}

Please provide a clear, simple, and runnable code example that directly answers the user's query.
If the query is about Flutter, provide Dart code.
Enclose the primary code solution in a single markdown code block (e.g., ```dart ... ``` or ```python ... ```).
Briefly explain the main parts of the code or any important considerations after the code block.
If the query is ambiguous, try to provide a common, foundational example.
"""
        else:
            # Original prompt for general queries
            full_prompt = f"""
Context from web search:
{context_text}

Query: {query}

Please provide a comprehensive, detailed, well-cited accurate response using the above context.
Think and reason deeply. Ensure it answers the query the user is asking. Do not use your knowledge until it is absolutely necessary to rely on the provided context.
"""
        print(f"[LLMService] Using prompt:\n{full_prompt[:500]}...\n") # Print start of the prompt

        try:
            response = self.model.generate_content(full_prompt, stream=True)
            for chunk in response:
                yield chunk.text
        except Exception as e:
            print(f"[LLMService] Error during content generation: {e}")
            yield f"An error occurred while generating the response: {str(e)}"