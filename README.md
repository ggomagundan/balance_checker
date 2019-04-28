# BalanceChecker

## PoloniexChecker

Need install some ruby gems
`dotenv`, `poloniex(my github gem)`, `pry`, `specific_install`

```sh
$ gem install dotenv
$ gem install pry
$ gem install specific_install
$ gem install poloniex
$ gem specific_install -l https://github.com/ggomagundan/poloniex.git
```

- Get API key on Poloniex [[Link]](https://poloniex.com/apiKeys)
- Update `.env` file
 ```
POLONIEX_KEY='POLONIEX_API_KEY'
POLONIEX_SECRET='POLONIEX_API_SECRET_KEY'
 ```

If you wanna link to `AWS dynamo` or `GCP datastore`
- dynamo
```
# Get AWS_ACCESS_KEY
# Update .env file like follow

AWS_ACCESS_KEY_ID='AWS_ACCESS_KEY_ID'
AWS_SECRET_ACCESS_KEY='AWS_SECRET_ACCESS_KEY'
AWS_REGION='ap-AWS_REGION'
```

- datastore
```
# Get GCP_ACCESS_KEY
# Update ~/.bashrc like follow

export GOOGLE_APPLICATION_CREDENTIALS

# Update ENVs
$ source ~/.bashrc
```
