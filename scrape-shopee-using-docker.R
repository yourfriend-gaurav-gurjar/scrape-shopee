library(RSelenium)
library(rvest)
library(tidyverse)
library(httr)

system('docker run -d -p 4445:4444 selenium/standalone-chrome')
Sys.sleep(5)
selenium_server_name = "localhost"
shopee_user = "hermandr@gmail.com"
shopee_password = "Nawamrad1"

remDr <-  RSelenium::remoteDriver(
  remoteServerAddr = selenium_server_name,
  port = 4445L,
  browserName = "chrome"
)

url="https://seller.shopee.co.id"
remDr$open()
remDr$navigate(url)
remDr$getCurrentUrl()
remDr$maxWindowSize()
Sys.sleep(5)
remDr$screenshot(file="seller-shopee-without-login.png")
#                             #app > div.app-container > div > div > div > div > div.login.col-6 > div > div > div > form > div:nth-child(1) > div > div > div > div > input
webElem <- remDr$findElement(
  using = "css",
  '#app > div.app-container > div > div > div > div > div.login.col-6 > div > div > div > form > div:nth-child(1) > div > div > div > div > input'
  )
#                            '#app > div.app-container > div > div > div > div > div.login.col-6 > div > div > div > form > div:nth-child(1) > div > div > div > div > input')

# Enter user name and password
webElem$sendKeysToElement(list(shopee_user,key="tab",
                               shopee_password,
                               key="enter"))
# Before click login
remDr$getCurrentUrl()
#webElem$clickElement()
#Render for 5 sec
Sys.sleep(5)

remDr$maxWindowSize()
remDr$screenshot(file="seller-shopee-after_login.png")

# Cookies Fetch
cookies = remDr$getAllCookies()
#    Convert to tibble

cookies %>%  as.matrix %>%
  as_tibble(.name_repair = "unique") %>% rename(V1=1) %>% 
  mutate( domain = map_chr(V1,"domain"),
  httpOnly = map_chr(V1,"httpOnly"),
  expiry = map(V1,"expiry"),
  #exp_length = map_int(expiry,length),
  name = map_chr(V1,"name"),
  path = map_chr(V1,"path"),
  secure = map_chr(V1,"secure"),
  value = map_chr(V1,"value")
) -> after_cookies



# after_cookies %>% unnest(expiry) -> after_cookies_with_expiry
# after_cookies %>%
#   select(name,value) %>%
#   mutate(cookie_string = paste(name,value,sep="=")) %>%
#   summarise(big_cookie = paste0(cookie_string,collapse = ";")) %>%
#   pull(big_cookie) %>%
#   write("big_cookie.txt")

#readr::write_csv(after_cookies %>% select(-V1, -expiry),path="cookies_all.csv")



#write_csv(after_cookies_with_expiry %>% select(-V1),path="cookies_with_expiry.csv")



##################
#https://seller.shopee.co.id/webchat/api/v1.2/mini/login?source=sc&_uid=0-240284413&_v=4.7.0&_api_source=sc

all_url <- remDr$executeScript('var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;')

all_url %>%
  as.matrix %>%
  as_tibble(.name_repair = "unique") %>% 
  rename(V1=1) %>% 
  mutate(name = map_chr(V1,"name")) %>% select(name) %>% str_extract("webchat")
# str(json_data, 1)
# map_dbl(json_data, length) %>% broom::tidy() %>% arrange(desc(x))
# str(json_data[[]])
# glimpse(json_data)
# as_tibble(json_data, validate = F)


# library(randomNames)
# new_names <- randomNames(126)
# json_data %>% as_data_frame()

# View(json_data_mat)
#unlist(json_data) -> json_data_unlist
#as_tibble(json_data_mat) %>% unlist() %>% View()
#%>% select(starts_with("https")) %>% View()
#json_data_mat[lapply(json_data_mat, length) > 32]

df <- data.frame(matrix(json_data, nrow=length(json_data), byrow=T))
select(df,name)
list.filter(df, name)
lapply(df, function(x){ x$name })
str(df[[]])$name %>% head()

# startsWith(json_data_unlist, "https://seller.shopee.co.id")
# json_data_unlist %>% filter(str_detect("https"))
# class(json_data_unlist)


GET(
  url = "https://seller.shopee.co.id/webchat/api/v1.2/mini/login?source=sc&_uid=0-240284413&_v=4.7.0&_api_source=sc", 
  set_cookies(),
  query = list(
    t = "ARCX:SPY", region = "usa", culture = "en-US", 
    cur = "", ops = "clear", s = "0P00001MK8", ndec = "2", ep = "true", 
    align = "q", annlz = "true", comparisonRemove = "false", 
    benchmarkSecId = "", benchmarktype = ""
  ),
  verbose()
) -> res
json_data[.][1]  
# library(httr)
# 
# GET(
#   url = "http://performance.morningstar.com/perform/Performance/cef/trailing-total-returns.action", 
#   add_headers(
#     Referer = "http://performance.morningstar.com/funds/etf/total-returns.action?t=SPY&region=USA&culture=en_US", 
#     `X-Requested-With` = "XMLHttpRequest"
#   ),
#   query = list(
#     t = "ARCX:SPY", region = "usa", culture = "en-US", 
#     cur = "", ops = "clear", s = "0P00001MK8", ndec = "2", ep = "true", 
#     align = "q", annlz = "true", comparisonRemove = "false", 
#     benchmarkSecId = "", benchmarktype = ""
#   ),
#   verbose()
# ) -> res

# We need to change this code a bit and then done. 
