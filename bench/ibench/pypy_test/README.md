# Setup
```
docker build -t pypy-test:latest .
```

# Run

Launch container:
```
docker run -it --rm --name pypy-test pypy-test bash
```

Execute benchmark with pypy:
```
python3 iibench.py ...
```
