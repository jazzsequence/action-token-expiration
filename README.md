# Token Expiration Checker
A GitHub action that will alert you if a required certificate has expired.

[![Tests](https://github.com/jazzsequence/action-token-expiration/actions/workflows/test.yml/badge.svg)](https://github.com/jazzsequence/action-token-expiration/actions/workflows/test.yml)
[![MIT License](https://img.shields.io/github/license/jazzsequence/action-token-expiration)](https://github.com/jazzsequence/action-token-expiration/blob/main/LICENSE) 
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/jazzsequence/action-token-expiration)](https://github.com/jazzsequence/action-token-expiration/releases)

## What's this do?

This action was designed to notify repository maintainers of expiring GitHub Personal Access Tokens. It will check the expiration date of a token and, if it's within the specified threshold, will display a notification or fail (depending on configuration) to hopefully give visibility into the tokens being used on a repository.

## Inputs
### `expiration`
**Required** The date that the token is set to expire. This should be in the format `YYYY-MM-DD`. Certs that never expire can be added here as well. In this case, the action will simply display the user associated with the token alongside a message that the token never expires. To use this action with a token that never expires, set the expiration date to `0000-00-00`.
### `token`
**Required** The token to check. This should be passed in as a secret. See [GitHub's documentation on secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) for more information.
### `token-name`
**Optional** How the token is identified. This is helpful (but not required) to provide identifying information about which token is expiring. It displays in the message when the action is run.
### `warn-days`
**Optional** The number of days before the token expires to warn. This should be an integer. Defaults to `30`.
### `error-early`
**Optional** If true, trigger an error (failure) before the token has actually expired. Uses the `warn-days` setting to determine how many days before the token expires to trigger the error. Defaults to `false`.

## Usage

```yaml
on:
  push:
    branches:
      - '**'
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Test Token Expiration
        uses: jazzsequence/action-token-expiration@main
        with:
          expiration: '2024-12-01'
          token: ${{ secrets.API_TOKEN }}
          token-name: 'action-token-expiration test token'
          warn-days: 30
          error-early: true
```