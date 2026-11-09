# Generating bakery product images in Canva

How the bakery product photos (`assets/images/catalog/p_*.png`) were made,
and how to add more. Any product without a photo shows the painted-donut
fallback, so a missing image never breaks a screen.

Canva exports a white background. The current photos had it removed by a flood
fill from the image edges, so white icing inside an item is kept; Canva's
**BG Remover** (step 5) does the same job.

## Products and file names

| Product | File name | Prompt subject |
|---|---|---|
| Butter Croissant | `p_butter_croissant.png` | a single golden butter croissant with flaky, shiny layers |
| Almond Croissant | `p_almond_croissant.png` | an almond croissant topped with toasted almond flakes and a dusting of powdered sugar |
| Cinnamon Roll | `p_cinnamon_roll.png` | a soft cinnamon roll swirl with white cream-cheese icing drizzled on top |
| Milk Bread Loaf | `p_milk_bread.png` | a Japanese milk bread loaf with a glossy golden-brown domed top |
| Red Velvet Cake Slice | `p_red_velvet_cake.png` | a slice of red velvet layer cake with thick white cream-cheese frosting layers |
| Chocolate Fudge Cake Slice | `p_choco_fudge_cake.png` | a slice of chocolate fudge layer cake with glossy dark ganache |

## Match the existing photos

The current product photos (`p_matcha.png`, `p_dalgona.png`, `p_coconut.png`):

- photorealistic studio food photography, soft even light, no harsh shadows
- **transparent background** (PNG with alpha); no plate, table or props
- one item only, centred and cropped tight with a small margin
- a slight top-down three-quarter angle (donuts look about 30° from above)
- about **640 px tall**, PNG, 300–700 KB

## Steps in Canva

1. **Create a design → Custom size → 1000 × 1000 px.**
2. Open **Apps → Magic Media → Images** (or *Dream Lab*).
3. Paste a prompt (template below). Style: **Photo**. Aspect ratio: **Square**.
4. Generate, then pick the result that is sharpest and closest to the others in
   angle and lighting. Regenerate if it adds plates, hands or text.
5. Click **Add to design**, select the image → **Edit → BG Remover**.
6. Resize the image so the item nearly fills the canvas, then use
   **Resize → Custom** (Canva Pro) or crop so the canvas hugs the item.
7. **Share → Download → PNG**, tick **Transparent background**, size so the
   height is about 640 px.
8. Rename the file to the name in the table above.

### Prompt template

```
Photorealistic studio food photograph of <prompt subject>, single item,
centred, slight top-down three-quarter angle, soft diffused lighting, crisp
detail, appetising, plain white background, no plate, no props, no text,
no hands
```

A plain white background makes BG Remover's cut-out cleaner than a coloured
or textured one.

## Adding the images to the project

Copy each PNG to **both** folders, keeping the exact file name:

```bash
cp p_*.png assets/images/catalog/                 # bundled, works offline
cp p_*.png mock_server/public/images/products/    # served by the mock API
```

Then fully restart the app (assets are not picked up by hot reload). No code
change is needed: the catalogue entries already point at these paths.

## Seasonal box photos (different style)

Seasonal specials show on a wide card that crops the photo to fill it, so
these are full scenes, **not** cut-outs. Match `p_mistletoe_box.jpg` and
`p_christmas_family.jpg`:

- an open kraft/gift box seen from directly above (flat lay), filling about
  70% of the frame
- white marble surface, with festive props only around the edges (pine
  branches, red ribbon, baubles) so the box stays clear when cropped
- bright, soft daylight; **square 800 × 800 px JPG**, about 150–200 KB

| Product | File name | Prompt subject |
|---|---|---|
| Gingerbread Donut Box | `p_gingerbread_box.jpg` | an open gift box of four gingerbread-spiced donuts with glossy cinnamon glaze, each topped with a small iced gingerbread man cookie |

### Seasonal prompt template

```
Top-down flat lay food photograph of <prompt subject>, on a white marble
table, pine branches, red ribbon and gold baubles around the edges, bright
soft daylight, photorealistic, crisp detail, no text, no hands
```

### Steps

1. **Create a design → Custom size → 800 × 800 px.**
2. **Apps → Magic Media → Images**, paste the prompt, Style **Photo**,
   Aspect ratio **Square**.
3. Pick the result that is sharpest and centred, **Add to design**, and
   stretch it to fill the canvas. Do **not** remove the background.
4. **Share → Download → JPG**, quality about 80, size 800 × 800.
5. Rename it to the file name in the table, then copy it into both folders:

```bash
cp p_gingerbread_box.jpg assets/images/catalog/
cp p_gingerbread_box.jpg mock_server/public/images/products/
```
