-- the avarage of energy of the tracks per decade
select
    floor(music_schema.date.year_number / 10) * 10 as decade,
    count(track_id) as number_of_tracks,
    avg(music_schema.track.energy) as avg_energy
from
    music_schema.date,
    music_schema.track
where
    music_schema.date.date_id = music_schema.track.release_date
group by
    decade
order by
    decade -- top 3 artists in terms of danceability per dacade 
select
    artist_name,
    decade,
    artist_rank,
    danceability
from
    (
        select
            *,
            RANK () OVER (
                PARTITION BY decade
                ORDER BY
                    danceability desc
            ) as artist_rank
        from
            (
                select
                    music_schema.artist.artist_name as artist_name,
                    floor(music_schema.date.year_number / 10) * 10 as decade,
                    count(music_schema.track.track_id) as number_of_tracks,
                    avg(music_schema.track.danceability) as danceability
                from
                    music_schema.track,
                    music_schema.track_artist,
                    music_schema.artist,
                    music_schema.date
                where
                    music_schema.date.date_id = music_schema.track.release_date
                    and music_schema.track.track_id = music_schema.track_artist.track_id
                    and music_schema.track_artist.artist_id = music_schema.artist.artist_id
                group by
                    (decade, artist_name)
                order by
                    decade,
                    danceability desc
            ) as best_dancing_artist_per_decade
        where
            number_of_tracks > 5
            and artist_name IS NOT NULL
    ) as ranking_best_artists
where
    artist_rank < 4;

-- characteristics on pop genre per artist and sub-genre
SELECT
    artist_name,
    genre,
    avg(energy),
    avg(danceability),
    avg(valence),
    avg(loudness)
from
    (
        -- for performance reasons the pop genre tracks are extracted before performing the join and the rollup
        select
            *
        from
            music_schema.track
        where
            track.genre LIKE 'pop%'
            OR track.genre LIKE '%-pop%'
            OR track.genre LIKE '% pop%'
            OR track.genre LIKE 'Pop%'
    ) as pop_tracks,
    music_schema.artist,
    music_schema.track_artist
where
    pop_tracks.track_id = music_schema.track_artist.track_id
    and music_schema.track_artist.artist_id = music_schema.artist.artist_id
group by
    rollup(artist_name, genre);

-- characteristics of releases per month and season of the year
Select
(
        case
            when month_number in (12, 1, 2) then 'winter'
            when month_number in (3, 4, 5) then 'spring'
            when month_number in (6, 7, 8) then 'summer'
            when month_number in (9, 10, 11) then 'autumn'
        end
    ) as "season",
    month_label,
    avg(valence) as Valence,
    avg(energy) as Energy
from
    music_schema.date,
    music_schema.track
where
    music_schema.date.date_id = music_schema.track.release_date
group by
    rollup(season, month_label) -- we note a small decrease in energy and small increase in valence in winter which is natural because people like more calm music in winter
    -- 
    -- pour cube , je vois pas de besoin de l'appliquer dans la nature de mon dataset