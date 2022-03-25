CREATE OR REPLACE FUNCTION music_schema.insert_date()

  RETURNS trigger AS

$$

BEGIN

INSERT INTO music_schema.date (date_id,day_number,month_number,year_number,month_label,week_day) 
VALUES(NEW.release_date,EXTRACT(DAY FROM NEW.release_date),EXTRACT(MONTH FROM NEW.release_date),EXTRACT(YEAR FROM NEW.release_date),to_char(NEW.release_date, 'Mon'),to_char(NEW.release_date,'Day'))
ON CONFLICT (date_id ) DO NOTHING;

RETURN NEW;

END;

$$

LANGUAGE 'plpgsql';

CREATE OR REPLACE  TRIGGER date_insert_trigger
  BEFORE INSERT
  ON music_schema.track
  FOR EACH ROW
  EXECUTE PROCEDURE music_schema.insert_date();