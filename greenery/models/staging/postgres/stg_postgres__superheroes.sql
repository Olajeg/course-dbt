Select 
id,
name,
gender,
eye_color,
race,
hair_color,
height,
publisher,
skin_color,
alignment,
weight,
created_at,
updated_at
from {{source('postgres','superheroes')}}