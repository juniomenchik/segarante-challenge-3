# Use the official Ruby image as the base image
FROM ruby:3.2.1

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Set environment variables directly in the Dockerfile
ENV RAILS_ENV=development \
    RACK_ENV=development \
    PORT=3000

# Create necessary directories
RUN mkdir -p tmp/pids

# Expose the port your app runs on
EXPOSE 3000

# Define the command to run your Rails application
CMD bundle exec rails db:create db:schema:load && bundle exec rails server -b 0.0.0.0
