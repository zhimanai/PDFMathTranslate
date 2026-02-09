FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app


EXPOSE 7860 11008

ENV PYTHONUNBUFFERED=1
ENV PDF2ZH_OFFLINE=1
ENV DOCLAYOUT_ONNX_PATH=/app/doclayout_yolo_docstructbench_imgsz1024.onnx

# # Download all required fonts
ADD "https://github.com/satbyy/go-noto-universal/releases/download/v7.0/GoNotoKurrent-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifCN-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifTW-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifJP-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifKR-Regular.ttf" /app/

RUN apt-get update && \
     apt-get install --no-install-recommends -y libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 supervisor && \
     rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN uv pip install --system --no-cache -r pyproject.toml && babeldoc --version && babeldoc --warmup

RUN python3 -c "from babeldoc.assets.assets import get_doclayout_onnx_model_path; import shutil; p=get_doclayout_onnx_model_path(); shutil.copy(p, '/app/doclayout_yolo_docstructbench_imgsz1024.onnx')"

COPY . .

RUN uv pip install --system --no-cache ".[backend]" && uv pip install --system --no-cache -U "babeldoc<0.3.0" "pymupdf<1.25.3" "pdfminer-six==20250416" && babeldoc --version && babeldoc --warmup

CMD ["/usr/bin/supervisord", "-c", "/app/docker/supervisord.conf"]
