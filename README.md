# Steps

1. Install Docker.

2. Copy `dotenv-dist` to `.env`.

3. Create a Thingiverse desktop API application: https://www.thingiverse.com/apps/create/  
This will generate an access token, client id and client secret.  
The access token does not have user permissions, and can only access public items.  
<br>If that's all you need, skip to step 4.

    1. If you want to fetch unpublished items as well, you'll need to create an access token for your Thingiverse user.  
    You'll need your client secret from the Thingiverse application you created.
    2. Visit: https://www.thingiverse.com/login/oauth/authorize?client_id=YOUR_CLIENT_SECRET&redirect_uri=http%3A%2F%2Flocalhost%3A9999&response_type=token
    3. Sign in, authorize your application, and copy the `access_token` parameter from the url 
when you're redirected back to localhost.

4. Run: `bin/run.sh <your thingiverse name>`
