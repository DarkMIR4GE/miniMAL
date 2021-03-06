%% Function to: 
%   1. scrape a user's (specified by username input) animelist from webpage
%   2. filter and clean the data
%   3. save the animelist as .csv in ../Data/User_AnimeLists/

        
function user_animelist = scrape_user_animelist(username)

    % selected features from source
    features = {'anime_id' 'anime_title' 'status' 'score'...
        'num_watched_episodes' 'anime_num_episodes' 'anime_airing_status'...
        'anime_media_type_string' 'anime_mpaa_rating_string'...
       'anime_start_date_string' 'anime_end_date_string'};

    
    url=['https://myanimelist.net/animelist/' username '/load.json?status=7&offset='];
    user_animelist = [];
     
    ... Could make the loop faster if 300 is declared as max entry/page ...
    while 1
        tic;
        try
            webpage = webread([url num2str(height(user_animelist))]);
        catch
            warning('Webpage not responding. Aborting...');
            return
        end
        if numel(webpage)==0
            break
        end
        nxt_page = struct2table(webpage);
        user_animelist = [user_animelist; nxt_page(:, features)];
        t = toc;
        if t < 4
            pause(4.2-t)
            % MAL could block your IP if multiple requests are made within 4 sec
        end
        %fprintf('Time taken %d sec\n',t);
    end
    
    
    ... Anime Status Codes      ...
    ... 1 - Watching            ...
    ... 2 - Completed           ...
    ... 3 - On Hold             ...
    ... 4 - Dropped             ...
    ... 6 - Plan to Watch       ...
        
    ... Airing Status Codes     ...
    ... 1 - Currently Airing    ...
    ... 2 - Finished Airing     ...
    ... 3 - Not Yet Aired       ...
    
    % cleaning and decoding data
    user_animelist.Properties.VariableNames = {'id' 'title' 'status' 'user_score'...
        'watchd_ep' 'total_ep' 'airing_status' 'media_type' 'mpaa_rating'...
        'start_date' 'end_date'};
    
    categoryName = {'Watching' 'Completed' 'Paused' 'Dropped' 'Planned'};
    user_animelist.status = categorical(user_animelist.status, [1:4 6], categoryName);
    user_animelist.user_score = categorical(user_animelist.user_score, 1:10, 'Ordinal', true);
    categoryName = {'Currently Airing' 'Finished Airing' 'Not Yet Aired'};
    user_animelist.airing_status = categorical(user_animelist.airing_status, 1:3, categoryName);
    categoryName = {'TV' 'Movie' 'OVA' 'ONA' 'Special' 'Music'};
    user_animelist.media_type = categorical(cellstr(char(user_animelist.media_type{:})), categoryName);
    categoryName = {'G' 'PG' 'PG-13' 'R' 'R+' 'Rx'};
    user_animelist.mpaa_rating = categorical(cellstr(char(user_animelist.mpaa_rating{:})), categoryName);
    user_animelist.start_date = datetime(char(user_animelist.start_date{:}), 'InputFormat', 'MM-dd-yy'); 
    user_animelist.end_date = datetime(char(user_animelist.end_date{:}), 'InputFormat', 'MM-dd-yy'); 
    
    
    % Saving user animelist as .csv
    filepath = ['..\Data\User_AnimeLists\' username '_list.csv'];
    writetable(user_animelist, filepath, 'Encoding', 'UTF-8');
    fprintf('User AnimeList %s_list.csv created\n',username);
    
end
