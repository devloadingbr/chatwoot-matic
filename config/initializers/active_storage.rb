# Fix for WhatsApp profile avatars appearing in grayscale (X-Ray Effect)
# Issue: https://github.com/chatwoot/chatwoot/issues/10863
#
# When fetching WhatsApp contact profile images via Evolution/Baileys API,
# Chatwoot was storing those images in grayscale instead of color.
# By default, Rails 7 / ActiveStorage was using Vips for image processing.
# The Vips-based pipeline might interpret the color profile incorrectly.

Rails.application.config.active_storage.variant_processor = :mini_magick