library(RSelenium)
library(rvest)
library(tidyverse)
library(httr)
library(hablar)
#install.packages("hablar", dependencies = T)

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
#  Convert to tibble
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

#after_cookies %>% View()

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

# Fetch 

url_string <- remDr$executeScript(
  'var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;'
  ) %>%
  as.matrix %>%
  as_tibble(.name_repair = "unique") %>% 
  rename(V1=1) %>% 
  mutate(name = map_chr(V1,"name")) %>% 
  select(name) %>%
  filter_all(all_vars(grepl('https://seller.shopee.co.id/webchat/api/v1.2/mini/login', .))) %>%
  as.character()


# cookie_name = c(after_cookies$name)
# cookie_value = c(after_cookies$value) %>% na_if("") %>% na.omit()

# https://seller.shopee.co.id/webchat/api/v1.2/mini/login?source=sc&_uid=0-240284413&_v=4.7.0&_api_source=sc

# SPC_CDS=b398e4ea-a1a9-403d-8bfb-8bd61763894f; UYOMAPJWEMDGJ=; SPC_SC_SA_TK=; SPC_SC_SA_UD=; SPC_SC_TK=dff7520fcda287e8721e3b6360a13e76; SPC_EC="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4="; SPC_F=ZgH2k9xUFhZGHuebP3ejyBCzNaVeD3WH; SPC_STK="iiPH/oOEHTw/B7q9MWPf26Qk2ZsRa3zr+5NfnaJPjyiVuutYi2JxEOMxkKEdQtC1mx/hXAQ6OT/H8n9KU+Xn5+E3IDjg/LTfqlpKMd1SyU+mJm88jwtk++ZjcJb/Vts6rA6eUjNtXBHY3ZrLyUIytVVRS6Wps1l/c82a3lLYZMvqdzHFAT12Ai0CFT2YZr+6"; SPC_SC_UD=240284413; SPC_WST="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4="; SPC_U=240284413; SC_DFP=6DdO23MxqsTrgTZOnQ3KhfbSJzLVzm1N

# ck = Request$new(
#             cookies = list(cookie_name, cookie_value))
# RestRserve::

# After cookies, convert them for dynamic query
cookie_uid = after_cookies %>% select(name, value) %>% 
  .[7,] %>% retype()


## Working Static post request to the Shopee account
POST(url = url_string,
     add_headers(
       `X-Requested-With` = "XMLHttpRequest"
     ),
#     user_agent()
     set_cookies(... = c(
                      after_cookies$name[1],
                      after_cookies$name[2],
                      after_cookies$name[3],
                      after_cookies$name[4],
                      after_cookies$name[5],
                      after_cookies$name[6],
                      cookie_uid$name[1],
                      after_cookies$name[12]),
                  .cookies = list(
                    after_cookies$value[1], after_cookies$value[2], after_cookies$value[3],
                    after_cookies$value[4], after_cookies$value[5], after_cookies$value[6], 240284413,after_cookies$value[12])),
     # set_cookies(after_cookies$name[1]=as.character(after_cookies$value[1]), after_cookies$name[2]=as.character(after_cookies$value[2]),
     #             after_cookies$name[3]=as.character(after_cookies$value[3]), after_cookies$name[4]=as.character(after_cookies$value[4]),
     #             after_cookies$name[5]=as.character(after_cookies$value[5]), after_cookies$name[6]=as.character(after_cookies$value[6]),
     #             after_cookies$name[7]=after_cookies$value[7],
     #             after_cookies$name[8]=as.character(after_cookies$value[8]), 
     #             after_cookies$name[9]=after_cookies$value[9],
     #             after_cookies$name[10]=as.character(after_cookies$value[10]), after_cookies$name[11]=as.character(after_cookies$value[11]),
     #             after_cookies$name[12]=as.character(after_cookies$value[12])),
  verbose()
  ) -> res

a = c(after_cookies$value[1],after_cookies$value[2],after_cookies$value[3], after_cookies$value[4],
  after_cookies$value[5],after_cookies$value[6], as.integer(after_cookies$value[7]), as.integer(after_cookies$value[9]),
  after_cookies$value[12])
## Working Static post request to the Shopee account
POST(url = url_string,
    add_headers(
      `X-Requested-With` = "XMLHttpRequest"
      ),    
    #set_cookies(... = cookie_name,
     #           .cookies = cookie_value),
    # UYOMAPJWEMDGJ=; SPC_SC_SA_TK=; SPC_SC_SA_UD=;
    set_cookies(SPC_CDS="b398e4ea-a1a9-403d-8bfb-8bd61763894f",
                SPC_SC_TK="dff7520fcda287e8721e3b6360a13e76",
                SPC_EC="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4=", 
                SPC_F="ZgH2k9xUFhZGHuebP3ejyBCzNaVeD3WH",
                SPC_STK="iiPH/oOEHTw/B7q9MWPf26Qk2ZsRa3zr+5NfnaJPjyiVuutYi2JxEOMxkKEdQtC1mx/hXAQ6OT/H8n9KU+Xn5+E3IDjg/LTfqlpKMd1SyU+mJm88jwtk++ZjcJb/Vts6rA6eUjNtXBHY3ZrLyUIytVVRS6Wps1l/c82a3lLYZMvqdzHFAT12Ai0CFT2YZr+6",
                SPC_SC_UD=240284413,
                SPC_WST="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4=",
                SPC_U=240284413,
                SC_DFP="6DdO23MxqsTrgTZOnQ3KhfbSJzLVzm1N"),
    verbose()
    
) -> res


content(res)

SPC_CDS=b398e4ea-a1a9-403d-8bfb-8bd61763894f; 
UYOMAPJWEMDGJ=; 
SPC_SC_SA_TK=; 
SPC_SC_SA_UD=; 
SPC_SC_TK=dff7520fcda287e8721e3b6360a13e76; 
SPC_EC="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4="; 
SPC_F=ZgH2k9xUFhZGHuebP3ejyBCzNaVeD3WH; 
SPC_STK="iiPH/oOEHTw/B7q9MWPf26Qk2ZsRa3zr+5NfnaJPjyiVuutYi2JxEOMxkKEdQtC1mx/hXAQ6OT/H8n9KU+Xn5+E3IDjg/LTfqlpKMd1SyU+mJm88jwtk++ZjcJb/Vts6rA6eUjNtXBHY3ZrLyUIytVVRS6Wps1l/c82a3lLYZMvqdzHFAT12Ai0CFT2YZr+6"; 
SPC_SC_UD=240284413; 
SPC_WST="Pemv8L5Oo3eeT3YioHplv+afyQcNMe7VcyQekErfUCklNFBjdHW0706+25NcXzb7hIHQuMexXBIaHuHzyIifu4ZPDzWp4EWZ/JoZz4mLzIiUj5ze5nZiw6ofQmHdqM0Z4O4kZWdr/x7lA+gUDyROyT3091sTNLHYiyF5S7IBOP4="; 
SPC_U=240284413; 
SC_DFP=6DdO23MxqsTrgTZOnQ3KhfbSJzLVzm1N


status_code(res)
View(res$content)
set_cookies(.cookies = c(after_cookies$name, after_cookies$value))
list(after_cookies$name, after_cookies$value) %>% View()
cookies(url_string)
ck <- cookies(res)$value
names(ck) <- cookies(res)$name
View(ck)

as_tibble(
  c(after_cookies$name, after_cookies$value)) %>% View()
# 
# POST(url = "https://seller.shopee.co.id/webchat/api/v1.2/mini/login",
#      add_headers(
#        Referer = "https://seller.shopee.co.id/webchat/api/v1.2/mini/login?source=sc&_uid=0-240284413&_v=4.7.0&_api_source=sc",
#        `X-Requested-With` = "XMLHttpRequest"
#      ),
#      queries =  list(
#        source = "sc",
#        uid = "0-240284413",
#        v = "4.7.0",
#        api_source="sc"    
#      ),
#      verbose()
# ) -> res

status_code(res)
content(res)$disclaimer
oauth_endpoint(res, )
GET(
  url = "http://performance.morningstar.com/perform/Performance/cef/trailing-total-returns.action",
  add_headers(
    Referer = "http://performance.morningstar.com/funds/etf/total-returns.action?t=SPY&region=USA&culture=en_US",
    `X-Requested-With` = "XMLHttpRequest"
  ),
  query = list(
    t = "ARCX:SPY", region = "usa", culture = "en-US",
    cur = "", ops = "clear", s = "0P00001MK8", ndec = "2", ep = "true",
    align = "q", annlz = "true", comparisonRemove = "false",
    benchmarkSecId = "", benchmarktype = ""
  ),
  verbose()
) -> res

# We need to change this code a bit and then done. 
