```
# to run the entire process 
python test_parallel.py --provider openrouter --model qwen --start_level 0 --end_level 34 --n_runs 64 --max_workers 4

# to only spin up the server and deploy task instance (port is for server, anvil runs on random, available port)
python handler.py --task_id 3 --port 1234 --task_source ethernaut

# to run only agent (handler server must be up and its port specified)
python agent.py --provider openrouter --model qwen --port 1234
```