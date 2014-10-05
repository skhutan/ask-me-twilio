SETUP
=========

- Add the WOLFRAM_APPID environment variable
- Setup Config.yaml with the IDs and Tokens from your Twilio Account by creating an app
- Add a url callback for /twil/received in your Twilio Account Panel and register the app with the voice and text callbacks 

Available Commands
------------------

Commands are sent with a preceding `#`

1. **Wolfram Alpha** - Ask the number and you'll get a call with the answer.
  Example:

  ```
    #wolfram Mass of the planet Earth
  ```
1. **Weather** - Send a request with a country or city to get the current
   weather texted back to you

  ```
    #weather london
  ```
