When("I visit the homepage") do
  visit root_path
end

Then("I should see weather") do
  expect(page).to have_content("Скоро тут будет погода..")
end
