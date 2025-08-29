
-------------------- PART A: CREATE SEQUENCES --------------------

CREATE SEQUENCE seqexp INCREMENT 20 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqallstrains INCREMENT 10 MINVALUE 1000 START 1000;
CREATE SEQUENCE seqallcomps INCREMENT 10 MINVALUE 1000 START 1000;
CREATE SEQUENCE seqthawdates INCREMENT 10 MINVALUE 100000 START 100000;
CREATE SEQUENCE seqwormthaws INCREMENT 10 MINVALUE 100000 START 100000;
CREATE SEQUENCE seqxstrainthaws INCREMENT 10 MINVALUE 1000000 START 1000000;
CREATE SEQUENCE seqxcomps INCREMENT 10 MINVALUE 1000000 START 1000000;
CREATE SEQUENCE seqxreps INCREMENT 10 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqxplate INCREMENT 10 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqobs INCREMENT 10 MINVALUE 100000000 START 100000000;
CREATE SEQUENCE seqdeaths INCREMENT 10 MINVALUE 100000000 START 100000000;



-------------------- PART B: CREATE TABLES --------------------

CREATE TABLE bacterial_strain_table (
  bacterial_strain_id INT NOT NULL UNIQUE,
  bacterial_strain_name VARCHAR PRIMARY KEY
);

CREATE TABLE experiment_type_table (
  experiment_type_id INT NOT NULL UNIQUE,
  experiment_type_name VARCHAR PRIMARY KEY
);

CREATE TABLE lab_table (
  lab_id INT NOT NULL UNIQUE,
  lab_name VARCHAR PRIMARY KEY
);

-- Change the start date interval to adjust for time zone.
CREATE TABLE experiment_table (
  experiment_id INT PRIMARY KEY,
  experiment_name VARCHAR UNIQUE,
  experiment_type_name VARCHAR REFERENCES experiment_type_table,
  bacterial_strain_name VARCHAR REFERENCES bacterial_strain_table,
  lab_name VARCHAR REFERENCES lab_table,
  start_date DATE NOT NULL DEFAULT NOW() - INTERVAL '7 hours',
  temperature DOUBLE PRECISION,
  notes VARCHAR,
  active_exp BOOLEAN NOT NULL DEFAULT TRUE,
  metadata_complete BOOLEAN NOT NULL DEFAULT FALSE,
  experiment_complete BOOLEAN NOT NULL DEFAULT FALSE,
  validated BOOLEAN NOT NULL DEFAULT FALSE,
  flag_for_del BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE manuscript_table (
  manuscript_id INT PRIMARY KEY,
  doi VARCHAR NOT NULL,
  author VARCHAR NOT NULL,
  journal VARCHAR NOT NULL,
  year INT NOT NULL,
  pmid INT
);

CREATE TABLE dataset_table (
  dataset_name VARCHAR PRIMARY KEY,
  manuscript_id INT REFERENCES manuscript_table ON DELETE CASCADE,
  dataset_description TEXT,
  display_order INT,
  comp_sort_order INT
);

CREATE TABLE xdatasets (
  dataset_name VARCHAR REFERENCES dataset_table ON DELETE CASCADE,
  experiment_id INT REFERENCES experiment_table ON DELETE CASCADE
);

CREATE TABLE species_table (
  species_id INT NOT NULL UNIQUE,
  species_name VARCHAR PRIMARY KEY
);

CREATE TABLE all_strains_table (
  strain_id INT PRIMARY KEY,
  strain_name VARCHAR NOT NULL UNIQUE,
  background VARCHAR,
  genotype VARCHAR,
  species_name VARCHAR REFERENCES species_table,
  active_strain BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE thaw_dates_table (
  thaw_date_id INT PRIMARY KEY,
  thaw_date DATE NOT NULL,
  lab_name VARCHAR REFERENCES lab_table,
  active_date BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE worm_thaws_table (
  worm_thaw_id INT PRIMARY KEY,
  active_thaw BOOLEAN NOT NULL DEFAULT TRUE,
  freeze_date DATE NOT NULL,
  strain_id INT REFERENCES all_strains_table ON DELETE CASCADE,
  thaw_date_id INT REFERENCES thaw_dates_table ON DELETE CASCADE
);

CREATE TABLE compound_controls_table (
  control_id INT NOT NULL UNIQUE,
  control_name VARCHAR PRIMARY KEY
);

CREATE TABLE all_compounds_table (
  comp_id INT PRIMARY KEY,
  comp_name VARCHAR NOT NULL UNIQUE,
  comp_abbr VARCHAR NOT NULL UNIQUE,
  active_comp BOOLEAN NOT NULL DEFAULT TRUE,
  control_name VARCHAR REFERENCES compound_controls_table ON DELETE CASCADE
);

CREATE TABLE compound_alt_names_table (
  comp_ref_id INT PRIMARY KEY,
  alternate_comp_name VARCHAR NOT NULL UNIQUE,
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE compound_metadata_table (
  comp_display_name VARCHAR NOT NULL UNIQUE,
  pubchem_id INT,
  comp_id INT UNIQUE REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE experimental_conditions_table (
  exp_cond_id INT PRIMARY KEY,
  exp_cond_name VARCHAR NOT NULL UNIQUE,
  active_exp_cond BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE xstrainthaws (
  xstrain_id INT PRIMARY KEY,
  egg_lay_date DATE NOT NULL,
  experiment_id INT REFERENCES experiment_table ON DELETE CASCADE,
  worm_thaw_id INT REFERENCES worm_thaws_table ON DELETE CASCADE
);

CREATE TABLE xcomps (
  xcomp_id INT PRIMARY KEY,
  concentration DOUBLE PRECISION NOT NULL,
  concentration_units VARCHAR NOT NULL,
  total_replicates INT DEFAULT 1 NOT NULL,
  exp_cond_id INT DEFAULT 1 REFERENCES experimental_conditions_table ON DELETE CASCADE,
  experiment_id INT REFERENCES experiment_table ON DELETE CASCADE, 
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE xreps (
  xrep_id INT PRIMARY KEY,
  replicate_num INT,
  xcomp_id INT REFERENCES xcomps ON DELETE CASCADE
);

CREATE TABLE tech_table (
  tech_initial VARCHAR PRIMARY KEY,
  tech_name VARCHAR,
  tech_id INT NOT NULL UNIQUE,
  active_tech BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE plate_table (
  plate_id INT PRIMARY KEY,
  plate_name VARCHAR,
  tech_initial VARCHAR REFERENCES tech_table DEFAULT 'UN',
  validated BOOLEAN NOT NULL DEFAULT FALSE,
  exclude_from_export BOOLEAN NOT NULL DEFAULT FALSE,
  hide_plate BOOLEAN NOT NULL DEFAULT FALSE,
  xrep_id INT REFERENCES xreps ON DELETE CASCADE,
  xstrain_id INT REFERENCES xstrainthaws ON DELETE CASCADE
);

CREATE TABLE observation_table (
  observation_id INT PRIMARY KEY,
  plate_id INT REFERENCES plate_table ON DELETE CASCADE,
  death_age DOUBLE PRECISION,
  observation_date DATE DEFAULT NOW() - INTERVAL '7 hours',
  alive INT,
  dead INT,
  censor INT,
  lost INT,
  wall INT,
  bag INT,
  extrusion INT,
  notes VARCHAR,
  validated BOOLEAN DEFAULT FALSE,
  del BOOLEAN DEFAULT FALSE
);

CREATE TABLE death_table (
  death_id INT PRIMARY KEY,
  observation_id INT REFERENCES observation_table ON DELETE CASCADE,
  indiv_death INT CHECK(indiv_death IN (1, 0)),
  indiv_censor INT CHECK(indiv_censor IN (1, 0)),
  censor_type VARCHAR
);

CREATE TABLE experiment_alm_alias_table (
  experiment_id INT NOT NULL REFERENCES experiment_table ON DELETE CASCADE,
  experiment_alias VARCHAR NOT NULL
);

CREATE TABLE plate_alm_info_table (
  plate_id INT UNIQUE REFERENCES plate_table ON DELETE CASCADE,
  device VARCHAR,
  plate_row INT,
  plate_column VARCHAR,
  total_worms INT,
  age_of_adult INT
);

CREATE TABLE death_alm_info_table (
  death_id INT UNIQUE REFERENCES death_table ON DELETE CASCADE,
  duration_not_fast_moving DOUBLE PRECISION
);

CREATE TABLE celest_experiment_table (
  celest_experiment_id INT PRIMARY KEY,
  experiment_name VARCHAR UNIQUE,
  celest_egg_lay_date DATE NOT NULL,
  lab_name VARCHAR REFERENCES lab_table,
  notes VARCHAR,
  flag_for_del BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE celest_date_table (
  celest_date_id INT PRIMARY KEY,
  celest_experiment_id INT REFERENCES celest_experiment_table ON DELETE CASCADE,
  celest_date DATE NOT NULL,
  adult_age INT NOT NULL
);

CREATE TABLE celest_xstraincomps (
  celest_xstraincomp_id INT PRIMARY KEY,
  celest_date_id INT REFERENCES celest_date_table ON DELETE CASCADE,
  strain_id INT REFERENCES all_strains_table ON DELETE CASCADE,
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE,
  tech_initial VARCHAR REFERENCES tech_table DEFAULT 'UN',
  trial_number INT NOT NULL
);

CREATE TABLE celest_video_table (
  celest_video_id INT PRIMARY KEY,
  celest_xstraincomp_id INT REFERENCES celest_xstraincomps ON DELETE CASCADE,
  video_name VARCHAR NOT NULL
);

CREATE TABLE celest_worm_measurement_table (
  celest_worm_measurement_id INT PRIMARY KEY,
  celest_video_id INT REFERENCES celest_video_table ON DELETE CASCADE,
  worm_number INT NOT NULL,
  wave_init_rate DOUBLE PRECISION NOT NULL, 
  body_wave_number DOUBLE PRECISION NOT NULL,
  asymmetry DOUBLE PRECISION NOT NULL,
  stretch DOUBLE PRECISION NOT NULL,
  curling DOUBLE PRECISION NOT NULL,
  travel_speed DOUBLE PRECISION NOT NULL,
  brush_stroke DOUBLE PRECISION NOT NULL,
  activity_index DOUBLE PRECISION NOT NULL
);

CREATE TABLE clone_observations_log (
  from_plate_item VARCHAR,
  to_plate_list VARCHAR,
  tech_initial VARCHAR,
  time_of_operation VARCHAR
);



ALTER TABLE experiment_table ALTER COLUMN experiment_id SET DEFAULT nextval('seqexp');
ALTER TABLE all_strains_table ALTER COLUMN strain_id SET DEFAULT nextval('seqallstrains');
ALTER TABLE thaw_dates_table ALTER COLUMN thaw_date_id SET DEFAULT nextval('seqthawdates');
ALTER TABLE worm_thaws_table ALTER COLUMN worm_thaw_id SET DEFAULT nextval('seqwormthaws');
ALTER TABLE all_compounds_table ALTER COLUMN comp_id SET DEFAULT nextval('seqallcomps');
ALTER TABLE xstrainthaws ALTER COLUMN xstrain_id SET DEFAULT nextval('seqxstrainthaws');
ALTER TABLE xcomps ALTER COLUMN xcomp_id SET DEFAULT nextval('seqxcomps');
ALTER TABLE xreps ALTER COLUMN xrep_id SET DEFAULT nextval('seqxreps');
ALTER TABLE plate_table ALTER COLUMN plate_id SET DEFAULT nextval('seqxplate');
ALTER TABLE observation_table ALTER COLUMN observation_id SET DEFAULT nextval('seqobs');
ALTER TABLE death_table ALTER COLUMN death_id SET DEFAULT nextval('seqdeaths');



-------------------- PART C: CREATE FUNCTIONS AND TRIGGERS --------------------

-- Update death records related to an observation.
CREATE FUNCTION updateDeaths()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM death_table WHERE (observation_id=NEW.observation_id AND indiv_death=1);
  FOR i IN 1..NEW.Dead LOOP
    INSERT INTO death_table(observation_id, indiv_death, indiv_censor)
    VALUES(NEW.observation_id, 1, 0);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateDeaths
  BEFORE INSERT OR UPDATE OF dead ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateDeaths();

-- Calculate censored value and update censored records related to an observation.
CREATE FUNCTION updateCensored()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.Censor = NEW.Lost + NEW.Wall + NEW.Bag + NEW.Extrusion;
  DELETE FROM death_table WHERE (observation_id=NEW.observation_id AND indiv_censor=1);
  FOR i IN 1..NEW.Censor LOOP
    INSERT INTO death_table(observation_id, indiv_death, indiv_censor)
    VALUES(NEW.observation_id, 0, 1);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateCensored
  BEFORE INSERT OR UPDATE OF censor, lost, wall, bag, extrusion ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateCensored();

-- Create new xreps whenever a new xcomps record is created.
CREATE FUNCTION addReps()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM xreps WHERE xcomp_id=NEW.xcomp_id;
  FOR i IN 1..NEW.total_replicates LOOP
    INSERT INTO xreps(xcomp_id, replicate_num)
    VALUES(NEW.xcomp_id, i);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER addReps
  AFTER INSERT OR UPDATE OF total_replicates ON xcomps
  FOR EACH ROW
  EXECUTE PROCEDURE addReps();

-- Calculate adult age when entering an observation date for a manual experiment.
CREATE FUNCTION updateDeathAge()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.death_age := (SELECT (NEW.observation_date - experiment_table.start_date) FROM experiment_table, xstrainthaws, plate_table, observation_table WHERE (observation_table.plate_id = plate_table.plate_id AND plate_table.xstrain_id = xstrainthaws.xstrain_id AND xstrainthaws.experiment_id = experiment_table.experiment_id  AND observation_table.observation_id = NEW.observation_id));
  RETURN NEW;
END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateDeathAge
  BEFORE INSERT OR UPDATE OF observation_date, observation_id ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateDeathAge();
