# Dockerfile
FROM python:3.12-slim
WORKDIR /app/OpenManus
RUN apt-get update && apt-get install -y --no-install-recommends git curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir uv

# Clona o OpenManus original
RUN git clone --depth=1 https://github.com/FoundationAgents/OpenManus /app/OpenManus

# Corrige o requirements: Pillow 10.x
RUN sed -i -E 's/^pillow[>=<~].*/pillow==10.4.0/' requirements.txt \
 || (echo 'pillow==10.4.0' >> requirements.txt)

# Instala dependências
RUN uv pip install --system -r requirements.txt

# O OpenManus é CLI. Você usará o Console para rodar.
CMD ["bash"]
