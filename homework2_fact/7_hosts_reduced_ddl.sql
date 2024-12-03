CREATE TABLE host_activity_reduced (
    month DATE NOT NULL,          
    host TEXT NOT NULL,           
    hit_array INTEGER[],          
    unique_visitors_array INTEGER[], 
    PRIMARY KEY (month, host)     
);