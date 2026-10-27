from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"message": "Hello, World!"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/test")
def test():
    return {"message": "test"}


@app.get("/test-rulset")
def rulset_def():
    return {"message": "rulset_def2"}