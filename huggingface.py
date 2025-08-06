# /// script
# requires-python = "==3.12"
# dependencies = [
#     "pandas>=2.3.0",
#     "plotly<=5.24.1",
# ]
# ///
import glob
import os
import pandas as pd
import pickle
import subprocess
import sys
from datetime import datetime

def clone_lmarena_repo():
    url = "https://huggingface.co/spaces/lmarena-ai/lmarena-leaderboard"
    repo = "lmarena"
    if not os.path.exists(repo):
        try:
            subprocess.run(["git", "lfs", "install", "--skip-repo"])
            subprocess.run(["git", "clone", "--depth", "1", url, repo], check=True)
        except subprocess.CalledProcessError:
            pass
    return repo

def get_date_from_filename(filename):
    return filename.split('_')[-1].split('.')[0]

def get_pkl_by_date(repo, target):
    files = glob.glob(f"{repo}/*.pkl")
    if not files:
        raise FileNotFoundError("No .pkl files found in the lmarena directory.")

    exact = f"{repo}/elo_results_{target}.pkl"
    if os.path.exists(exact):
        return exact

    older = [f for f in files if get_date_from_filename(f) < target]
    if older:
        older.sort(key=get_date_from_filename, reverse=True)
        print(f"File not found: {exact}. Using {older[0]} instead.", file=sys.stderr)
        return older[0]
    
    files.sort(key=get_date_from_filename, reverse=True)
    print(f"File not found: {exact}. Using latest file {files[0]} instead.", file=sys.stderr)
    return files[0]

def get_date_version(repo, argv):
    if len(argv) > 2:
        raise ValueError("Expected 0 or 1 arguments, got {}".format(len(argv) - 1))
    elif len(argv) == 2:
        target = argv[1].replace(".", "")
    else:
        target = datetime.now().strftime("%Y%m%d")

    filename = get_pkl_by_date(repo, target)
    date = get_date_from_filename(filename)

    return date, filename

def load_lmarena_data(filename, subset):
    with open(filename, 'rb') as f:
        data = pickle.load(f)
    if isinstance(data, dict) and subset in data:
        subset_data = data[subset]
        if 'full' in subset_data:
            return subset_data['full']['leaderboard_table_df']
    else:
        raise ValueError("Leaderboard data not found.")

def load_lmarena_metadata(repo, date):
    filename = f"{repo}/leaderboard_table_{date}.csv"
    return pd.read_csv(filename)

def build_full_leaderboard(leaderboard, metadata):
    lm = leaderboard.merge(metadata, left_index=True, right_on='key')
    df = pd.DataFrame({
        'rank': range(1, len(lm) + 1),
        'rank_stylectrl': lm['final_ranking'].values.astype(int),
        'model': lm['Model'].values,
        'arena_score': lm['rating'].values.astype(int),
        '95_pct_ci': [
            f"+{int(upper - rating)}/-{int(rating - lower)}" 
            for rating, upper, lower in zip(
                lm['rating'].values,
                lm['rating_upper'].values,
                lm['rating_lower'].values
            )
        ],
        'votes': lm['num_battles'].values.astype(int),
        'organization': lm['Organization'].values,
        'license': lm['License'].values,
        'knowledge_cutoff': lm['Knowledge cutoff date'].replace('-', '').values,
        'url': lm['Link'].values,
    })
    return df

def build_directory(dir):
    if not os.path.exists(dir):
        os.makedirs(dir)
    return dir

def build_lmarena_leaderboards(metadata, filename):
    dir = build_directory("csv")
    subsets = ['text', 'vision', 'image']
    for subset in subsets:
        leaderboard = load_lmarena_data(filename, subset)
        df = build_full_leaderboard(leaderboard, metadata)
        csv = f"{dir}/lmarena_{subset}.csv"
        df.to_csv(csv, index=False)

repo = clone_lmarena_repo()
date, filename = get_date_version(repo, sys.argv)
metadata = load_lmarena_metadata(repo, date)
build_lmarena_leaderboards(metadata, filename)
