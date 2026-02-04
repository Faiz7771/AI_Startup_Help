from datetime import datetime

from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import check_password
from django.http import JsonResponse
from django.shortcuts import render, redirect
from django.contrib.auth.models import User, Group
from django.views.decorators.csrf import csrf_exempt
# Create your views here.
from myapp.models import Viewstartup, Notifications, Complaints, Experts, Feedback, Review_rating, Students, Doubt, \
    Student_requests, Skills, Bookmark

# from django.shortcuts import render
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# import google.generativeai as genai
# import json
# import time
#
# # Optional: pause briefly to avoid rate limit
# time.sleep(6)
#
# # Configure Gemini API once
# GOOGLE_API_KEY = 'YOUR_API_KEY_HERE'
# genai.configure(api_key='AIzaSyBsMwoNlD17X3aReEvkGWxz4Y0R8DAU0VQ')
# model = genai.GenerativeModel("gemini-2.5-flash")
#
#
# @csrf_exempt
# def chatbot_response(request):
#     if request.method == 'POST':
#         try:
#             data = json.loads(request.body)
#             user_input = data.get('message', '').strip()
#
#             if not user_input:
#                 return JsonResponse({'reply': "Please type something to chat."})
#
#             # Create a conversational prompt
#             prompt = (
#                 f"You are a friendly and knowledgeable AI assistant For an deepfake detection app"
#                 f"Respond naturally and helpfully to this message:\n\n"
#                 f"User: {user_input}\nAI:"
#             )
#
#             # Generate response
#             response = model.generate_content(prompt)
#
#             return JsonResponse({'reply': response.text.strip()})
#
#         except Exception as e:
#             print('Error',str(e))
#             return JsonResponse({'reply': f"Error: {str(e)}"})
#
#     return JsonResponse({'reply': "Invalid request method."})

# =======================JOB RECOMMENTATION AI CODE STARTING ---------------------
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from .models import Students, Skills, Viewstartup  # Import your models
import google.generativeai as genai
import json
import time
from django.db.models import Q

# Configure Gemini API
GOOGLE_API_KEY = 'AIzaSyDlprQxZJg23xLd3j9cZFFrz_vp29CsXHA'
genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel("gemini-2.5-flash")

def get_startup_recommendations(user_skills, user_id, limit=3):
    """
    Match user skills with startup ideas.
    limit = number of startup ideas to return
    """

    try:
        # ---- FETCH USER PROFILE ----
        student = Students.objects.get(login_id=user_id)
        user_skill_obj = Skills.objects.get(user=student)

        tech_skills = user_skill_obj.tech_skills.lower()
        interests = user_skill_obj.interests.lower()
        pref_industry = (user_skill_obj.pref_industry or "").lower()

        tech_list = [s.strip() for s in tech_skills.split(',') if s.strip()]
        interest_list = [i.strip() for i in interests.split(',') if i.strip()]

        # ---- SKILL → TECH MAP ----
        SKILL_KEYWORDS = {
            "python": ["python"],
            "machine learning": ["ml", "ai", "llm", "neural", "model"],
            "web": ["react", "next", "node", "express", "frontend", "backend"],
            "mobile": ["flutter", "react native", "android", "ios"],
            "blockchain": ["blockchain", "web3", "smart contract"],
            "cloud": ["aws", "azure", "gcp", "docker", "kubernetes"],
        }

        startups = Viewstartup.objects.all()
        matched_startups = []

        for startup in startups:
            startup_tech = startup.technologies.lower()
            startup_title = startup.title.lower()
            startup_desc = startup.description.lower()

            score = 0
            reasons = set()

            # ---- TECH MATCH ----
            for skill in tech_list:
                for key, keywords in SKILL_KEYWORDS.items():
                    if key in skill:
                        if any(k in startup_tech for k in keywords):
                            score += 3
                            reasons.add(f"Uses {key} technologies")
                        break

            # ---- INTEREST MATCH ----
            for interest in interest_list:
                if interest in startup_title or interest in startup_desc:
                    score += 2
                    reasons.add(f"Aligns with interest in {interest}")

            # ---- INDUSTRY MATCH ----
            if pref_industry and (
                pref_industry in startup_title or pref_industry in startup_desc
            ):
                score += 2
                reasons.add(f"Related to {pref_industry} industry")

            if score > 0:
                matched_startups.append({
                    "title": startup.title,
                    "description": startup.description[:180] + "...",
                    "technologies": startup.technologies,
                    "score": score,
                    "match_reason": "; ".join(reasons)
                })

        # ---- SORT & LIMIT ----
        matched_startups.sort(key=lambda x: x["score"], reverse=True)
        matched_startups = matched_startups[:limit]

        if not matched_startups:
            return "No suitable startup ideas found for your current skill set."

        # ---- FORMAT RESPONSE ----
        response = "STARTUP IDEAS RECOMMENDED FOR YOU\n\n"
        for idx, s in enumerate(matched_startups, 1):
            response += (
                f"{idx}. {s['title']}\n"
                f"   {s['description']}\n"
                f"   Tech Stack: {s['technologies']}\n"
                f"   Why it matches: {s['match_reason']}\n\n"
            )

        response += f"Skills considered: {tech_skills} | Interests: {interests}"
        return response

    except Students.DoesNotExist:
        return "User profile not found."
    except Skills.DoesNotExist:
        return "Skill profile not found."
    except Exception as e:
        return f"Recommendation error: {str(e)}"


@csrf_exempt
def chatbot_response(request):
    if request.method != 'POST':
        return JsonResponse({'reply': "Invalid request method."})

    try:
        data = json.loads(request.body)
        user_input = data.get('message', '').strip()
        user_id = data.get('user_id')

        if not user_input:
            return JsonResponse({'reply': "Please type something to chat."})

        user_text = user_input.lower()

        # ---- STARTUP INTENT DETECTION ----
        startup_keywords = ['startup', 'idea', 'business', 'venture']

        single_idea_phrases = [
            "one idea",
            "a startup idea",
            "single idea",
            "give me an idea",
            "suggest an idea",
            "one startup"
        ]

        multiple_idea_phrases = [
            "ideas",
            "list",
            "recommend",
            "suggest some",
            "multiple",
            "all ideas"
        ]

        if user_id and any(k in user_text for k in startup_keywords):

            if any(p in user_text for p in single_idea_phrases):
                limit = 1
            elif any(p in user_text for p in multiple_idea_phrases):
                limit = 3
            else:
                # Default → ONE strong idea
                limit = 1

            recommendation = get_startup_recommendations(
                user_skills=None,
                user_id=user_id,
                limit=limit
            )
            return JsonResponse({'reply': recommendation})

        # ---- GENERAL CHAT (GEMINI) ----
        skill_obj = Skills.objects.get(user__login_id=user_id)
        name = skill_obj.user.name
        academics = skill_obj.academics
        skills = skill_obj.tech_skills
        interests = skill_obj.interests

        startups = list(Viewstartup.objects.values(
            "title", "description", "technologies"
        ))

        prompt = f"""
                You are a helpful startup and career assistant.

                    User Profile:
                            Name: {name}
                        Academics: {academics}
Skills: {skills}
Interests: {interests}

Startup Ideas Database:
{startups}

Rules:
- If the user asks for ONE idea, give only ONE.
- If the user asks for multiple ideas, give up to THREE.
- Be concise and practical.

User message:
"{user_input}"
"""

        response = model.generate_content(prompt)
        return JsonResponse({'reply': response.text.strip()})

    except Exception as e:
        return JsonResponse({'reply': f"Sorry, something went wrong: {str(e)}"})

# =======================JOB RECOMMENTATION AI CODE ENDING-----------------------
def public(request):
    return render(request, "public.html")

def logins(request):
    return render(request, "login.html")

def login_post(request):
    username=request.POST['USERNAME']
    password=request.POST['PASSWORD']
    user=authenticate(request,username=username,password=password)
    print(user)

    if user is not None:
        if user.groups.filter(name="Admin").exists():
            login(request,user)
            print(request.user)
            return redirect('/myapp/admin_homepage/')
        elif user.groups.filter(name='Expert').exists():
            login(request,user)
            return redirect('/myapp/expert_homepage/')
        else:
            messages.warning(request,'Following user is not considered an Admin or Expert')
            return redirect('/myapp/login/')
    else:
        messages.warning(request,'Invalid user or password')
        return redirect('/myapp/login/')

def signup(request):
    return render(request, "signup.html")

def admin_home(request):
    return render(request, "Admin/admin_main_home.html")

def add_idea(request):
    return render(request, "Admin/add_idea.html")

def add_idea_post(request):
    title=request.POST['TITLE']
    description=request.POST['DESCRIPTION']
    technology=request.POST['TECHNOLOGY']
    from datetime import datetime
    a=Viewstartup()
    a.title=title
    a.description=description
    a.technologies=technology
    a.date=datetime.now().today()
    a.save()
    return redirect('/myapp/add_idea/')

def edit_idea(request,id):
    d=Viewstartup.objects.get(id=id)
    return render(request, "Admin/edit_idea.html",{'data':d})

def edit_idea_post(request):
    title=request.POST['TITLE']
    description=request.POST['DESCRIPTION']
    technology=request.POST['TECHNOLOGY']
    id=request.POST['id']
    a=Viewstartup.objects.get(id=id)
    a.title=title
    a.description=description
    a.technologies=technology
    a.save()
    return redirect('/myapp/view_idea/')

def add_notif(request):
    return render(request, "Admin/add_notif.html")

def add_notif_post(request):
    title=request.POST['TITLE']
    notification=request.POST['NOTIFICATION']
    from datetime import datetime
    a=Notifications()
    a.title=title
    a.notification=notification
    a.date = datetime.now().today()
    a.save()
    return redirect('/myapp/add_notif/')

def send_reply(request,id):
    d = Complaints.objects.get(id=id)
    return render(request, "Admin/send_reply.html",{'data':d})

def send_reply_post(request):
    reply = request.POST['REPLY']
    id = request.POST['id']
    Complaints.objects.filter(id=id).update(reply=reply)
    return redirect('/myapp/view_complaints_reply/')


def change_pass_a(request):
    return render(request, "Admin/change_pass_a.html")

def change_pass_a_post(request):
    currentpass=request.POST['CURRENTPASS']
    newpass = request.POST['NEWPASS']
    confirmpass = request.POST['CONFIRMPASS']
    user=request.user
    print(user)
    if not check_password(currentpass, user.password):
        messages.error(request,'current password is not correct....!')
        return redirect('/myapp/change_pass_a/')
    if newpass==confirmpass:
        user.set_password(newpass)
        user.save()
        messages.error(request,'Password changed successfully')
        return redirect('/myapp/login/')
    else:
        messages.error(request,'Password does not match')
        return redirect('/myapp/change_pass_a/')

def view_students(request):
    a=Students.objects.all()
    return render(request, "Admin/view_students.html",{'data':a})

def view_experts(request):
    a=Experts.objects.all()
    return render(request, "Admin/view_experts.html",{'data':a})

def approve_experts(request,id):
    a=Experts.objects.get(id=id)
    a.status="Approved"
    a.save()
    return redirect("/myapp/view_experts/")

def reject_experts(request,id):
    a=Experts.objects.get(id=id)
    a.status="Rejected"
    a.save()
    return redirect("/myapp/view_experts/")

def view_idea(request):
    a=Viewstartup.objects.all()
    return render(request, "Admin/view_idea.html",{'data':a})

def delete_idea(request, id):
    a=Viewstartup.objects.filter(id=id).delete()
    return redirect("/myapp/view_idea/")

def view_notif(request):
    a=Notifications.objects.all()
    return render(request, "Admin/view_notif.html",{'data':a})

def delete_notif(request, id):
    a=Notifications.objects.filter(id=id).delete()
    return redirect("/myapp/view_notif/")

def view_feedback_a(request):
    a=Feedback.objects.all()
    return render(request, "Admin/view_feedback_a.html",{'data':a})

def view_review_rating(request):
    a=Review_rating.objects.all()
    return render(request, "Admin/view_review_rating.html",{'data':a})

def view_complaints_reply(request):
    a = Complaints.objects.all()
    return render(request, "Admin/view_complaints_reply.html", {'data': a})

def view_reply(request):
    a=Complaints.objects.all
    return render(request, "Admin/view_reply.html",{'data':a})

def expert_homepage(request):
    a=request.user.id
    b=Experts.objects.get(login_id=a)
    return render(request, "Expert/expert_homepage.html",{'data':b})

def register_expert(request):
    return render(request, "Expert/register_expert.html")

def register_expert_post(request):
    name=request.POST['NAME']
    email=request.POST['EMAIL']
    phone=request.POST['PHONENO']
    photo=request.FILES['PHOTO']
    place=request.POST['PLACE']
    post=request.POST['POST']
    pin=request.POST['PIN']
    district=request.POST['DISTRICT']
    proof=request.FILES['PROOF']
    password=request.POST['PASSWORD']
    if User.objects.filter(username=email).exists():
        messages.warning(request, 'User already exists!')
        return redirect("/myapp/register_expert")
    else:
        user=User.objects.create_user(username=email,password=password,)
        user.groups.add(Group.objects.get(name='Expert'))
        a=Experts()
        a.name=name
        a.email=email
        a.phone=phone
        a.photo=photo
        a.place=place
        a.post=post
        a.pin=pin
        a.district=district
        a.proof=proof
        a.login=user
        a.status='pending'
        a.save()
        messages.success(request, 'Successfully created an expert account.')
        return redirect("/myapp/login/")

#WIP

def add_idea_e(request):
    return render(request, "Expert/add_idea_e.html")

def add_idea_e_post(request):
    title=request.POST['TITLE']
    description=request.POST['DESCRIPTION']
    technology=request.POST['TECHNOLOGY']
    from datetime import datetime
    a=Viewstartup()
    a.title=title
    a.description=description
    a.technologies=technology
    a.date=datetime.now().today()
    a.save()
    return redirect('/myapp/add_idea_e/')

def view_idea_e(request):
    a=Viewstartup.objects.all()
    return render(request, "Expert/view_idea_e.html",{'data':a})

def delete_idea_e(request, id):
    a=Viewstartup.objects.filter(id=id).delete()
    return redirect("/myapp/view_idea_e/")

#WIP

def view_profile_e(request):
    a=request.user.id
    b=Experts.objects.get(login_id=a)
    return render(request, "Expert/view_profile_e.html",{'data':b})

def edit_profile(request):
    a=Experts.objects.get(login_id=request.user.id)
    return render(request, "Expert/edit_profile.html",{'data':a})

def edit_profile_post(request):
    name = request.POST['NAME']
    phone = request.POST['PHONENO']
    place = request.POST['PLACE']
    post = request.POST['POST']
    pin = request.POST['PIN']
    district = request.POST['DISTRICT']
    a = Experts.objects.get(login_id=request.user.id)
    a.name = name
    a.phone = phone
    if 'PHOTO' in request.FILES:
        photo = request.FILES['PHOTO']
        a.photo = photo
    a.place = place
    a.post = post
    a.pin = pin
    a.district = district
    if 'PROOF' in request.FILES:
        proof = request.FILES['PROOF']
        a.proof = proof
    a.status = 'pending'
    a.save()
    return redirect("/myapp/view_profile_e/")

def view_student_doubts(request):
    a=Doubt.objects.all()
    return render(request, "Expert/view_student_doubts.html")

def view_feedback_e(request):
    a=Feedback.objects.all()
    return render(request, "Expert/view_feedback_e.html",{'data':a})

def view_review_rating_e(request):
    a=Review_rating.objects.all()
    return render(request, "Expert/view_review_rating_e.html",{'data':a})

def view_studentdoubts(request):
    a=Doubt.objects.all()
    return render(request, "Expert/view_studentdoubts.html",{'data':a})

def view_requests(request):
    a=Student_requests.objects.all()
    return render(request, "Expert/view_requests.html",{'data':a})

def send_reply_e(request,id):
    a=Doubt.objects.get(id=id)
    return render(request, "Expert/send_reply_e.html",{'data':a})

def send_reply_e_post(request):
    reply = request.POST['REPLY']
    id = request.POST['id']
    Doubt.objects.filter(id=id).update(reply=reply,status='Replied')
    return redirect('/myapp/view_studentdoubts/')

def send_reply_e2(request,id):
    a=Student_requests.objects.get(id=id)
    return render(request, "Expert/send_reply_e2.html",{'data':a})

def send_reply_e2_post(request):
    request_reply = request.POST['REPLY']
    id = request.POST['id']
    Student_requests.objects.filter(id=id).update(request_reply=request_reply,status='Replied')
    return redirect('/myapp/view_requests/')

def change_pass_e(request):
    return render(request, "Expert/change_pass_e.html")

def change_pass_e_post(request):
    currentpass = request.POST['CURRENTPASS']
    newpass = request.POST['NEWPASS']
    confirmpass = request.POST['CONFIRMPASS']
    user = request.user
    print(user)
    if not check_password(currentpass, user.password):
        messages.error(request, 'current password is not correct....!')
        return redirect('/myapp/change_pass_e/')
    if newpass == confirmpass:
        user.set_password(newpass)
        user.save()
        messages.error(request, 'Password changed successfully')
        return redirect('/myapp/login/')
    else:
        messages.error(request, 'Password does not match')
        return redirect('/myapp/change_pass_e/')


def logout(request):
    request.session.flush()
    return redirect("/myapp/login/")


def Login_page(request):
    email = request.POST['Email']
    password = request.POST['Password']
    user = authenticate(request, username=email, password=password)
    print(user)
    if user is not None:
        if User.objects.filter(username=email).exists():
            data=user.id
            return JsonResponse({'message':'Login successful','data':data})
        else:
            return JsonResponse({'message':'Invalid Email or Password'})
    else:
        return JsonResponse({'message':'Invalid Email or Password'})


def register_page(request):
    name=request.POST['name']
    email=request.POST['email']
    password=request.POST['password']
    place=request.POST['place']
    district=request.POST['district']
    state=request.POST['state']
    phone=request.POST['phone']
    pin=request.POST['pin']
    if User.objects.filter(username=email).exists():
        return JsonResponse({'status':'User already exists!'})
    else:
        user=User.objects.create_user(username=email,password=password,)
        user.groups.add(Group.objects.get(name='User'))
        a=Students()
        a.name=name
        a.email=email
        a.phone=phone
        if 'photo' in request.FILES:
            photo = request.FILES['photo']
            a.photo = photo
        a.place = place
        a.district = district
        a.state = state
        a.phone = phone
        a.pin = pin
        a.login=user
        a.save()
        return JsonResponse({'status':'Customer registered successfully!'})


def user_home(request):
    login_id = request.POST['login_id']

    user = Students.objects.get(login_id=login_id)

    photo_url = ""
    if user.photo:
        photo_url = user.photo.url

    print(photo_url)

    return JsonResponse({
        "status": "success",
        "photo": photo_url,
    })

def manage_profile(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    photo_url = user.photo.url
    name=user.name
    email=user.email
    place=user.place
    district=user.district
    state=user.state
    phone=user.phone
    pin=user.pin

    try:
        skills = Skills.objects.get(user__login_id=login_id)
        academics = skills.academics
        tech_skills = skills.tech_skills
        interests = skills.interests
        pref_industry = skills.pref_industry
        investment_cap = skills.investment_cap

    except Skills.DoesNotExist:
        academics = ""
        tech_skills = ""
        interests = ""
        pref_industry = ""
        investment_cap = ""
    # dets = Skills.objects.filter(user__login_id=login_id).exists()
    #
    # if dets!=None:
    #     academics=dets.academics
    #     tech_skills=dets.tech_skills
    #     interests=dets.interests
    #     pref_industry=dets.pref_industry
    #     investment_cap=dets.investment_cap

    return JsonResponse({
        "photo": photo_url,
        "name":name,
        "email":email,
        "place":place,
        "district":district,
        "state":state,
        "phone":phone,
        "pin":pin,
        "academics": academics,
        "tech_skills":tech_skills,
        "interests":interests,
        "pref_industry":pref_industry,
        "investment_cap":investment_cap
    })

def Editprof(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    photo_url = user.photo.url
    name = user.name
    email = user.email
    place = user.place
    district = user.district
    state = user.state
    phone = user.phone
    pin = user.pin
    return JsonResponse({
        "photo": photo_url,
        "name": name,
        "email": email,
        "place": place,
        "district": district,
        "state": state,
        "phone": phone,
        "pin": pin,
    })

def Editprof_post(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    name = request.POST['name']
    email = request.POST['email']
    place = request.POST['place']
    district = request.POST['district']
    state = request.POST['state']
    phone = request.POST['phone']
    pin = request.POST['pin']
    a = Students.objects.get(login_id=login_id)
    a.name = name
    a.email = email
    a.phone = phone
    if 'photo' in request.FILES:
        photo = request.FILES['photo']
        a.photo = photo
    a.place = place
    a.district = district
    a.state = state
    a.phone = phone
    a.pin = pin
    a.save()
    return JsonResponse({'status': 'User details Edited Successfully!'})

def Changepass(request):
    login_id = request.POST['login_id']
    user = User.objects.get(id=login_id)
    oldpassword=request.POST['oldpass']
    newpassword = request.POST['newpass']
    confirmpassword= request.POST['confirmpass']
    if user.check_password(oldpassword):
        user.set_password(newpassword)
        user.save()
        return JsonResponse({'status':'Password Changed successfully!'})
    if newpassword==confirmpassword:
        user.set_password(newpassword)
        user.save()
        return JsonResponse({'status':'Password Changed successfully!'})
    else:
        return JsonResponse({'status':'Incorrect Password'})
    return JsonResponse({'status':'ok'})

def Expert_idea(request):
    student_id = request.POST['student_id']
    user = Students.objects.get(login_id=student_id).id
    description = request.POST['description']
    a = Student_requests()
    a.student_id=user
    a.description = description
    a.request_reply='pending'
    a.expert_id=2
    a.date=datetime.now()
    a.status='pending'
    a.save()
    return JsonResponse({"status":"Request Submitted Successfully!"})

def Expert_idea_post(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    s = Student_requests.objects.filter(student=user)
    l1=[]
    for i in s:
        l1.append({
            'id':i.id,
            'description':i.description,'date':i.date,
                   'reply':i.request_reply,'Expert Name':i.expert.name,
                   'Expert Status':i.expert.status})
    print(l1)
    return JsonResponse({'status':'ok','data':l1})


def add_bookmark(request):
    student_id = request.POST['student_id']
    idea_id= request.POST['id']

    print(idea_id,'fgdgfdfgf')
    user = Students.objects.get(login_id=student_id).id
    print(user,'hdfghhgv')
    a = Bookmark()
    a.user_id = user
    a.idea_id = idea_id
    a.save()
    return JsonResponse({"status": "Bookmarked Successfully!"})


def Complaints_user(request):
    user_id = request.POST['user_id']
    user = Students.objects.get(login_id=user_id).id
    complaints = request.POST['complaints']
    a = Complaints()
    a.user_id = user
    a.date = datetime.now()
    a.complaints = complaints
    a.reply = 'pending'
    a.save()
    return JsonResponse({"status": "Complaint Submitted Successfully!"})

def Complaints_user_post(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    s = Complaints.objects.filter(user_id=user)
    l1=[]
    for i in s:
        l1.append({'complaint':i.complaints,'reply':i.reply,
                   'date':i.date})
    print(l1)
    return JsonResponse({'status':'ok','data':l1})

def Doubts_user(request):
    user_id = request.POST['user_id']
    user = Students.objects.get(login_id=user_id).id
    doubt = request.POST['doubt']
    a = Doubt()
    a.user_id = user
    a.doubt=doubt
    a.expert_id = 2
    a.date = datetime.now()
    a.reply = 'pending'
    a.status='pending'
    a.save()
    return JsonResponse({"status": "Doubt Submitted Successfully!"})

def Doubts_user_post(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    s = Doubt.objects.filter(user_id=user)
    l1=[]
    for i in s:
        l1.append({'doubt':i.doubt,'status':i.status,'reply':i.reply,
                   'date':i.date})
    print(l1)
    return JsonResponse({'status':'ok','data':l1})

def Feedback_user(request):
    user_id = request.POST['user_id']
    user = Students.objects.get(login_id=user_id).id
    feedback=request.POST['feedback']
    a = Feedback()
    a.user_id = user
    a.date = datetime.now()
    a.feedback = feedback
    a.save()
    return JsonResponse({"status": "Feedback Submitted Successfully!"})

def Feedback_user_post(request):
    login_id = request.POST['login_id']
    user = Students.objects.get(login_id=login_id)
    s = Feedback.objects.filter(user_id=user)
    l1=[]
    for i in s:
        l1.append({'feedback':i.feedback,'date':i.date})
    print(l1)
    return JsonResponse({'status':'ok','data':l1})

def Rating_review(request):
    user_id = request.POST['user_id']
    user = Students.objects.get(login_id=user_id).id
    rating = request.POST['rating']
    review = request.POST['review']
    a = Review_rating()
    a.date = datetime.now()
    a.rating= rating
    a.review = review
    a.user_id = user
    a.save()
    return JsonResponse({"status": "Complaint Submitted Successfully!"})

def Rating_review_post(request):
    login_id=request.POST['login_id']
    user=Students.objects.get(login_id=login_id)
    s=Review_rating.objects.all()
    l1 = []
    for i in s:
        l1.append({'rating':i.rating,'review':i.review,'username':i.user.name,'date':i.date})
    print(l1)
    return JsonResponse({'status':'ok','data':l1})


def save_student_details(request):
    """
    Save or update student details in the skills table
    """
    if request.method == 'POST':
        try:
            # Get all POST data
            login_id = request.POST.get('login_id')
            academics = request.POST.get('academics', '')
            tech_skills = request.POST.get('tech_skills', '')
            interests = request.POST.get('interests', '')
            pref_industry = request.POST.get('pref_industry', '')
            investment_cap = request.POST.get('investment_cap', '')

            # Validate required fields
            if not login_id:
                return JsonResponse({'status': 'error', 'message': 'Login ID required'})

            if not academics and not tech_skills and not interests and not pref_industry and not investment_cap:
                return JsonResponse({'status': 'error', 'message': 'Please fill at least one field'})

            # Get the student
            try:
                student = Students.objects.get(login_id=login_id)
            except Students.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'Student not found'})

            # Check if skills/details already exist for this student
            try:
                # Update existing record in skills table
                skills_record = Skills.objects.get(user_id=student.id)
                skills_record.academics = academics
                skills_record.tech_skills = tech_skills
                skills_record.interests = interests
                skills_record.pref_industry = pref_industry
                skills_record.investment_cap = investment_cap
                skills_record.save()

                return JsonResponse({'status': 'success', 'message': 'Student details updated successfully'})

            except Skills.DoesNotExist:
                # Create new record in skills table
                skills_record = Skills.objects.create(
                    user_id=student.id,
                    academics=academics,
                    tech_skills=tech_skills,
                    interests=interests,
                    pref_industry=pref_industry,
                    investment_cap=investment_cap
                )
                skills_record.save()

                return JsonResponse({'status': 'success', 'message': 'Student details saved successfully'})

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})


@csrf_exempt
def get_bookmarks(request):
    """Fetch all bookmarks for a student"""
    try:
        student_id = request.POST.get('student_id')
        if not student_id:
            return JsonResponse({'status': 'error', 'message': 'Student ID required'})

        # Get student object using login_id
        student = Students.objects.get(login_id=student_id)

        # Get all bookmarks for this student
        bookmarks = Bookmark.objects.filter(user=student).select_related('idea', 'idea__expert')

        bookmarks_list = []
        for bookmark in bookmarks:
            idea = bookmark.idea
            bookmarks_list.append({
                'bookmark_id': bookmark.id,
                'id': idea.id,
                'description': idea.description,
                'date': idea.date.strftime('%Y-%m-%d') if idea.date else '',
                'reply': idea.request_reply,
                'Expert Name': idea.expert.name if idea.expert else '',
                'Expert Status': idea.expert.status if idea.expert else '',
            })

        return JsonResponse({'status': 'ok', 'data': bookmarks_list})

    except Students.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Student not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


@csrf_exempt
def remove_bookmark(request):
    """Remove a bookmark"""
    try:
        student_id = request.POST.get('student_id')
        bookmark_id = request.POST.get('bookmark_id')

        if not student_id or not bookmark_id:
            return JsonResponse({'status': 'error', 'message': 'Missing parameters'})

        # Get student object
        student = Students.objects.get(login_id=student_id)

        # Find and delete the bookmark
        bookmark = Bookmark.objects.filter(id=bookmark_id, user=student).first()

        if not bookmark:
            return JsonResponse({'status': 'error', 'message': 'Bookmark not found'})

        bookmark.delete()

        return JsonResponse({'status': 'Bookmark removed successfully!'})

    except Students.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Student not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})