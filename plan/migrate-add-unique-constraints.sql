USE [GameStore]
GO

-- cart_items: 1 user khong mua cung 1 game 2 lan
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_cart_items_user_game')
BEGIN
    ALTER TABLE cart_items
    ADD CONSTRAINT UQ_cart_items_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_cart_items_user_game'
END ELSE PRINT 'UQ_cart_items_user_game already exists'

-- library_items: moi license key chi gan 1 lan
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_library_items_license')
BEGIN
    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_license UNIQUE (license_key_id)
    PRINT 'Added UQ_library_items_license'
END ELSE PRINT 'UQ_library_items_license already exists'

-- library_items: khong mua lai game da co
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_library_items_user_game')
BEGIN
    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_library_items_user_game'
END ELSE PRINT 'UQ_library_items_user_game already exists'

-- reviews: moi user chi review 1 game 1 lan
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_reviews_user_game')
BEGIN
    ALTER TABLE reviews
    ADD CONSTRAINT UQ_reviews_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_reviews_user_game'
END ELSE PRINT 'UQ_reviews_user_game already exists'

-- wishlists: khong them cung game vao wishlist 2 lan
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_wishlists_user_game')
BEGIN
    ALTER TABLE wishlists
    ADD CONSTRAINT UQ_wishlists_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_wishlists_user_game'
END ELSE PRINT 'UQ_wishlists_user_game already exists'

GO
PRINT 'All unique constraints checked'
