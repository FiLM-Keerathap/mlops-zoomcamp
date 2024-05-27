import os
import pickle
import click
import math
import mlflow
from mlflow.models import infer_signature
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

mlflow.set_tracking_uri("http://127.0.0.1:5000")
mlflow.set_experiment("nyc-taxi-experiment")


def load_pickle(filename: str):
    with open(filename, "rb") as f_in:
        return pickle.load(f_in)


@click.command()
@click.option(
    "--data_path",
    default="./output",
    help="Location where the processed NYC taxi trip data was saved",
)
def run_train(data_path: str):
    with mlflow.start_run():
        mlflow.set_tag("developer", "FiLM")
        mlflow.log_param("train-data-path", os.path.join(data_path, "train.pkl"))
        X_train, y_train = load_pickle(os.path.join(data_path, "train.pkl"))
        mlflow.log_param("valid-data-path", os.path.join(data_path, "val.pkl"))
        X_val, y_val = load_pickle(os.path.join(data_path, "val.pkl"))

        rf = RandomForestRegressor(max_depth=10, random_state=0)
        rf.fit(X_train, y_train)
        y_pred = rf.predict(X_val)
        params = rf.get_params()
        mlflow.log_params(params)

        # Infer the model signature
        signature = infer_signature(X_train, rf.predict(X_train))

        rmse = math.sqrt(mean_squared_error(y_val, y_pred))
        mlflow.log_metric("rmse", rmse)
        # Log the model
        model_info = mlflow.sklearn.log_model(
            sk_model=rf,
            artifact_path="artifacts",
            signature=signature,
            input_example=X_train,
            registered_model_name="tracking-quickstart",
        )


if __name__ == "__main__":
    run_train()
