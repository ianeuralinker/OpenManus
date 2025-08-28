# Dockerfile
FROM python:3.12-slim

# 1) deps básicos
RUN apt-get update && apt-get install -y --no-install-recommends git curl \
    && rm -rf /var/lib/apt/lists/*

# 2) pip rápido
RUN pip install --no-cache-dir uv

# 3) diretório de trabalho
WORKDIR /app/OpenManus

# 4) traga o projeto upstream para dentro da imagem
RUN git clone --depth=1 https://github.com/FoundationAgents/OpenManus /app/OpenManus

# 5) fix no Pillow (compatibilidade)
RUN sed -i -E 's/^pillow[>=<~].*/pillow==10.4.0/' requirements.txt \
    || (echo 'pillow==10.4.0' >> requirements.txt)

# 6) instale requirements do projeto
RUN uv pip install --system -r requirements.txt

# 7) garanta FastAPI/uvicorn (caso upstream mude no futuro)
RUN uv pip install --system fastapi "uvicorn[standard]"

# 8) copie o wrapper web (este arquivo vem do seu repositório)
#    IMPORTANTE: o build do Coolify manda seu repo como contexto, então esse COPY funciona.
COPY app.py /app/OpenManus/app.py

# 9) configs de runtime
ENV PYTHONUNBUFFERED=1 \
    OPENMANUS_DIR=/app/OpenManus

# 10) porta web
EXPOSE 8000

# 11) suba a API
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
