import csv
from collections import Counter

import rows
from tqdm import tqdm

reader = csv.DictReader(rows.utils.open_compressed("data/output/socio.csv.gz"))
paises = Counter((row["codigo_pais"], row["nome_pais"]) for row in tqdm(reader))
print(paises.most_common())
