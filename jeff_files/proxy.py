from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    flow.response.content = flow.response.content.decode().replace("Do your best on today's test!","Hey, How will you prepare for next week's test?").encode()
