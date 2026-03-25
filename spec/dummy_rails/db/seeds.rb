# frozen_string_literal: true
#
# Improvements over previous version:
#
# 1. `frozen_string_literal: true`  — avoids unnecessary String allocations for every literal.
# 2. `ApplicationRecord.transaction` — atomicity: a failure anywhere rolls the whole seed back.
# 3. `delete_all` over `destroy_all` — skips ActiveRecord callbacks and validations; orders of
#    magnitude faster for bulk teardown where those side-effects are irrelevant.
# 4. Ordered `delete_all` respects FK constraints without disabling them.
# 5. `tag_map` as a local variable — constants defined in seed.rb leak into the global namespace
#    and raise "already initialised" warnings on every subsequent `db:seed` run.
# 6. `days_ago.days.ago.to_date` — idiomatic Rails; reads like English and handles DST correctly.
# 7. `PostTag.insert_all!` — collapses N individual INSERT statements into one, which is the
#    single biggest query-count win available in this file.

ApplicationRecord.transaction do
  # 1. Clean up — order matters: children before parents to satisfy FK constraints.
  puts "Cleaning database..."
  [PostTag, Tag, Post, Profile, Author].each(&:delete_all)

  # 2. Tags
  puts "Creating tags..."
  tag_map = {
    tech:   Tag.create!(name: "Technology"),
    travel: Tag.create!(name: "Travel"),
    food:   Tag.create!(name: "Food")
  }

  # 3. Authors + Profiles
  puts "Creating authors and profiles..."
  [
    { name: "Alice Smith", age: 30, email: "alice@example.com", bio: "Tech enthusiast and coder." },
    { name: "Bob Jones",   age: 45, email: "bob@example.com",   bio: "Global traveler and food critic." }
  ].each do |data|
    author = Author.create!(name: data[:name], age: data[:age], email: data[:email])
    Profile.create!(author: author, description: data[:bio])
  end

  # 4. Posts
  puts "Creating posts..."
  alice = Author.find_by!(email: "alice@example.com")
  bob   = Author.find_by!(email: "bob@example.com")

  posts_data = [
    {
      title:       "The Future of Rails 7",
      description: "Exploring the new features in the latest Rails update.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    0
    },
    {
      title:       "Best Pasta in Rome",
      description: "A deep dive into the culinary wonders of Italy.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel food],
      published:   true,
      days_ago:    1
    },
    {
      title:       "Intro to Hotwire and Turbo",
      description: "How Hotwire is changing the way we think about front-end in Rails.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    2
    },
    {
      title:       "Hidden Gems of Southeast Asia",
      description: "Off-the-beaten-path destinations you need to visit.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel],
      published:   true,
      days_ago:    3
    },
    {
      title:       "Ruby Performance Tips",
      description: "Practical techniques to squeeze more speed out of your Ruby code.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    4
    },
    {
      title:       "Street Food of Bangkok",
      description: "Navigating the incredible street food scene of Thailand's capital.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel food],
      published:   true,
      days_ago:    5
    },
    {
      title:       "Understanding ActiveRecord Callbacks",
      description: "A guide to using—and avoiding—callbacks in Rails models.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    6
    },
    {
      title:       "A Week in Kyoto",
      description: "Temples, matcha, and slow mornings in Japan's ancient capital.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel food],
      published:   true,
      days_ago:    7
    },
    {
      title:       "Designing RESTful APIs with Rails",
      description: "Best practices for building clean and maintainable JSON APIs.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   false,
      days_ago:    8
    },
    {
      title:       "The Art of Sourdough",
      description: "Everything you need to start baking your own sourdough bread.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[food],
      published:   true,
      days_ago:    9
    },
    {
      title:       "Background Jobs with Sidekiq",
      description: "How to offload work and keep your Rails app responsive.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    10
    },
    {
      title:       "Road Trip Through Patagonia",
      description: "Wind, glaciers, and endless roads at the end of the world.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel],
      published:   true,
      days_ago:    11
    },
    {
      title:       "Securing Your Rails Application",
      description: "A practical checklist for locking down common Rails vulnerabilities.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    12
    },
    {
      title:       "Ramen Beyond the Packet",
      description: "Crafting a rich tonkotsu broth from scratch at home.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[food],
      published:   true,
      days_ago:    13
    },
    {
      title:       "Caching Strategies in Rails",
      description: "Fragment, action, and low-level caching explained with examples.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   false,
      days_ago:    14
    },
    {
      title:       "Sailing the Greek Islands",
      description: "What a two-week sailing trip through the Cyclades taught me.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel],
      published:   true,
      days_ago:    15
    },
    {
      title:       "Testing with RSpec: Beyond the Basics",
      description: "Shared examples, custom matchers, and keeping your test suite fast.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    16
    },
    {
      title:       "Fermentation at Home",
      description: "Kimchi, kombucha, and kefir—why fermented foods are worth the effort.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[food],
      published:   true,
      days_ago:    17
    },
    {
      title:       "Multi-tenancy in Rails with Apartment",
      description: "Schema-based multi-tenancy patterns for SaaS applications.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    18
    },
    {
      title:       "Morocco on Two Wheels",
      description: "Cycling from Marrakech to the Sahara and back.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[travel food],
      published:   true,
      days_ago:    19
    },
    {
      title:       "Deploying Rails with Kamal",
      description: "Zero-downtime deploys to your own server without the Heroku price tag.",
      category:    "Software",
      author:      alice,
      tags:        %i[tech],
      published:   true,
      days_ago:    20
    },
    {
      title:       "The Perfect Neapolitan Pizza",
      description: "Flour, water, salt, yeast—and a very hot oven.",
      category:    "Lifestyle",
      author:      bob,
      tags:        %i[food],
      published:   true,
      days_ago:    21
    }
  ]

  # Accumulate PostTag rows while creating posts, then flush in one INSERT.
  post_tag_rows = []

  posts_data.each_with_index do |data, index|
    post = Post.create!(
      title:       data[:title],
      description: data[:description],
      state:       index % 3,
      category:    data[:category],
      dt:          data[:days_ago].days.ago.to_date,
      position:    (index + 1).to_f,
      published:   data[:published],
      author:      data[:author]
    )

    data[:tags].each do |tag_key|
      post_tag_rows << { post_id: post.id, tag_id: tag_map[tag_key].id }
    end
  end

  # 5. Single-query bulk insert for all join-table rows.
  puts "Linking posts to tags..."
  PostTag.insert_all!(post_tag_rows)

  puts "Successfully seeded #{Author.count} authors, #{Post.count} posts, and #{Tag.count} tags!"
end
