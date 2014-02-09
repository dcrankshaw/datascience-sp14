
1. Lab 1 Deja vu ! Print the number of requests that had HTTP return code 404. Next break down
number of 404 requests by date (i.e how many on 30th April and how many on 1st May).

Part 1:

    grouped = log_df.groupby('ResponseCode')
    grouped.size()[404]

Part 2:
    day_grouped = log_df.groupby(lambda row: log_df['DateTime'][row].day)
    day_grouped.apply(lambda x: x.groupby('ResponseCode').size())

2. What is the average file size for images (.gif or .jpg or .jpeg files) which
had response code 200 ? What is the standard deviation ?

    ok_url_sizes = log_df[log_df['ResponseCode'] == 200][['URL', 'Size']]
    img_urls =  ok_url_sizes[ok_url_sizes.apply(lambda row: ".gif" in row['URL'] or ".jpeg" in row['URL'] or ".jpg" in row['URL'], axis=1)]
    img_urls['Size'].mean()
    img_urls['Size'].std()

3. Generate a histogram of traffic to the site every *half-hour*. Plot this using matplotlib. 
    half_hour_grouped = log_df.groupby(lambda row: pd.to_datetime(str(log_df['DateTime'][row].hour) + ":" + str((log_df['DateTime'][row].minute / 30)*30)))
    half_hour_grouped.size().plot()

4. 
