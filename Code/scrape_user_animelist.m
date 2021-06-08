%% Function to: 
%   1. scrape a user's (specified by username input) animelist from webpage
%   2. clean the data
%   3. save the animelist as .csv in ../Data/User_AnimeLists/

... Anime Status                ...
    ... 1 - Currently Watching  ...
    ... 2 - Completed           ...
    ... 3 - On Hold             ...
    ... 4 - Dropped             ...
    ... 6 - Plan to Watch       ...
        
function user_animelist = scrape_user_animelist(username)

    url=['https://myanimelist.net/animelist/' username '/load.json?status=7&offset='];
    webpage = webread([url '0']);
    user_animelist = struct2table(webpage);
    features = {'anime_id' 'anime_title' 'status' 'score'...
        'num_watched_episodes' 'anime_num_episodes' 'anime_airing_status'...
        'anime_media_type_string' 'anime_mpaa_rating_string'...
        'anime_start_date_string' 'anime_end_date_string'};
    user_animelist = user_animelist(:, features);
    t = 0;
    
    ... Could make the loop faster if 300 is declared as max entry/page ...
    while 1
        if t < 4
            pause(4.2-t)
            % MAL could block your IP if multiple requests are made within 4 sec
        end
        tic;
        webpage = webread([url num2str(height(user_animelist))]);
        if numel(webpage)==0
            break
        end
        nxt_page = struct2table(webpage);
        user_animelist = [user_animelist; nxt_page(:, features)];
        t = toc;
        %fprintf('Time taken %d sec\n',t);
    end

    user_animelist.Properties.VariableNames = {'id' 'title' 'status' 'user_score'...
        'watchd_ep' 'total_ep' 'airing_status' 'media_type' 'mpaa_rating'...
        'release_date' 'completion_date'};
    filepath = ['..\Data\User_AnimeLists\' username '_list.csv'];
    writetable(user_animelist, filepath);
    fprintf('User AnimeList %s_list.csv created\n',username);
    
end
